# Polyfill for String.contains
if !String.prototype.contains?
	String.prototype.contains = (needle, startIndex) ->
		-1 isnt String.prototype.indexOf.call(this, needle, startIndex)

tablesize = 6
tablePos = 0

like = (haystack, needle) ->
	haystack.toLowerCase().contains needle.toLowerCase()

isNumber = (value) ->
	if !value?
		return false

	if typeof value is 'number'
		return true

	!isNaN(value - 0)

inFilter = (mov) ->
	filterVal = $('#movFilter').val()

	if !filterVal? or filterVal.trim() == ""
		return true

	if isNumber filterVal
		n = parseFloat(filterVal)
		if n < 10 and mov.rating >= n
			return true
		if n > 1500 and mov.year is n 
			return true

	like(mov.label, filterVal) or like(mov.originaltitle, filterVal) or like(mov.genre.join(), filterVal)

cut = (str, l) ->
	if Array.isArray(str)
		str = str.join(", ")
	if str.length - 3 > l
		return "#{str.substr(0, l - 3)}..."
	if str?
		""

shortDate = (d) ->
	d = new Date(d.substr(0,10))
	"#{d.getDate()}.#{d.getMonth() + 1}.#{d.getFullYear()}"

updateList = (skip) ->
	$('table.movies tbody').html ''

	if skip > data.length
		skip = data.length

	count = 0
	gcount = 0
	for mov in data
		gcount++
		if inFilter mov
			
			if skip > 0
				skip--
				continue

			selClass = ""
			selClass = " sel" if $('.details .id').html() is mov.movieid.toString()

			count++
			if count < tablesize
				$('table.movies tbody').append """
					<tr data-p="#{gcount}" data-id="#{mov.movieid}" class="#{selClass}">
						<td>#{mov.label}</td>
						<td>#{mov.originaltitle}</td>
						<td>#{mov.year}</td>
						<td>#{mov.rating.toPrecision(2)}</td>
						<td>#{shortDate(mov.dateadded)}</td>
						<td class="show-for-medium-up">#{cut(mov.genre, 25)}</td>
					</tr>"""

	if count >= tablesize
		$('table.movies tfoot td.amount').html("and #{count - tablesize + 1} more...")
	else
		$('table.movies tfoot td.amount').html("")

getMovie = (id) ->
	for mov in data
		return mov if mov.movieid is id

getCastList = (mov) ->
	str = "<dl class=inline-list>"
	for pers in mov.cast
		str += "<dt>#{pers.name}</dt><dd>#{pers.role}</dd>"
	str += "</dl>"

updateDetails = (id) ->
	mov = getMovie id
	if mov?
		$('.details .year').html mov.year
		$('.details .title').html mov.label
		$('.details .tagline').html mov.tagline
		$('.details .plot').html mov.plot
		$('.details .genre').html mov.genre.join(", ")
		$('.details .cast').html getCastList mov
		$('.details .writer').html mov.writer.join(", ")
		$('.details .director').html mov.director.join(", ")
		$('.details .country').html mov.country
		$('.details .id').html mov.movieid
		$('.details .poster').attr('src', "")
		$('.details .poster').attr('data-original', "./thumbs/#{id}.jpg")
		$('.details .poster').lazyload(
			effect: 'fadeIn'
			event: 'load'
		)
		$('.details .poster').trigger 'load'

goToPos = (pos, dir) ->

	dir = 'left' if !dir?

	if dir is 'left' or $('.movies tbody tr.sel').data('p') < pos
		dir = "right"
		dirI = "left"
	else
		dir = "left"
		dirI = "right"

	targetRow = $(".movies tbody tr[data-p=#{pos}]")

	$('.movies tbody tr.sel').removeClass 'sel'
	targetRow.addClass 'sel'

	id = targetRow.data('id')
	if $('.details:visible').length <= 0
		$('.clickToDetail').hide()
		updateDetails id
		$('.details').show 'drop'
	else
		$('.details').hide(
			'drop'
				direction: dirI
			->
				updateDetails id
				$('.details').show(
					'drop'
						direction: dir
				)
		)

ascSort = (a, b) ->
	($(b).text()) < ($(a).text()) ? 1 : -1;

genericSort = (a, b) ->
	if a < b
		return -1
	else
		return 1
	return 0

labelSort = (a, b) ->
	genericSort(a.label, b.label)

originaltitleSort = (a, b) ->
	genericSort(a.originaltitle, b.originaltitle)

yearSort = (a, b) ->
	genericSort(a.year, b.year)

ratingSort = (a, b) ->
	genericSort(a.rating, b.rating)

dateaddedSort = (a, b) ->
	genericSort(a.dateadded, b.dateadded)

lastCol = 'dateadded'
lasOrdAsc = true
sortDataBy = (colName) ->

	if lastCol is colName
		order = if lasOrdAsc then 'desc' else 'asc'
		lasOrdAsc = !lasOrdAsc
	else
		lasOrdAsc = false

	lastCol = colName

	switch colName
		when 'label' then data.sort labelSort
		when 'originaltitle' then data.sort originaltitleSort
		when 'year' then data.sort yearSort
		when 'rating' then data.sort ratingSort
		when 'dateadded' then data.sort dateaddedSort

	if order is 'desc'
		data.reverse()

$ ->

	$('#movFilter').on(
		'keyup', 
		->
			tablePos = 0
			updateList()
	)

	$('span.for').click ->
		tablePos += tablesize - 1
		updateList tablePos

	$('span.back').click ->
		tablePos -= tablesize - 1
		tablePos = 0 if tablePos < 0
		updateList tablePos

	$('.movies tbody').on(
		'click', 
		'tr',
		->
			goToPos $(@).data 'p'

	)

	$('.addToSelection').click ->
		$('.selectionHint').hide()
		id = $('.id').html()
		if $(".selection li.id-#{id}").length <= 0
			$('.selection ul').append("<li class=\"id-#{id}\">#{$('.title').html()}</li>")
			$('.selection ul > li').sort(ascSort).appendTo('.selection ul')

	$('body').on(
		'keydown'
		(e) ->
			if e.keyCode is 39 or e.keyCode is 37

				if $('.movies tbody tr.sel').data('p')? 
					pos = $('.movies tbody tr.sel').data 'p'
					switch e.keyCode
						when 39 then pos++
						when 37 then pos--

					pos = 1 if pos < 1
				else
					pos = 1

				if pos > $('.movies tbody tr').last().data 'p'
					tablePos += tablesize - 1
					dir = 'left'
					updateList tablePos
				else if pos < $('.movies tbody tr').first().data 'p'
					tablePos -= tablesize - 1
					dir = 'right'
					updateList tablePos

				goToPos(pos, dir)
	)

	$('table.movies th[data-sort]').click (e) ->
		e.preventDefault()

		$('table.movies th[data-sort]').removeClass 'active'
		$(@).addClass 'active'

		sortCol = $(@).data('sort')

		sortDataBy sortCol

		tablePos = 0
		updateList()

	updateList()