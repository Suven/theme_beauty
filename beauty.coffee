# Polyfill for String.contains
if !String.prototype.contains?
	String.prototype.contains = (needle, startIndex) ->
		-1 isnt String.prototype.indexOf.call(this, needle, startIndex)

$ ->
	tablesize = 6
	tablePos = 0

	like = (haystack, needle) ->
		haystack.contains needle

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
		count = 0
		for mov in data
			if inFilter mov
				skip--

				if skip >= 1
					continue

				count++

				if count < tablesize
					$('table.movies tbody').append "
						<tr data-id=\"#{mov.movieid}\">
							<td>#{mov.label}</td>
							<td>#{mov.originaltitle}</td>
							<td>#{mov.year}</td>
							<td>#{mov.rating.toPrecision(2)}</td>
							<td class=\"show-for-medium-up\">#{cut(mov.genre, 25)}</td>
							<td>#{shortDate(mov.dateadded)}</td>
						</tr>"

		if count > tablesize
			$('table.movies tfoot td.amount').html("and #{count - tablesize} more...")
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
			$('.details .poster').attr('src', "./thumbs/#{id}.jpg")

	$('#movFilter').on(
		'keyup', 
		->
			tablePos = 0
			updateList()
	)

	$('span.for').click ->
		tablePos += tablesize
		updateList tablePos

	$('span.back').click ->
		tablePos -= tablesize
		tablePos = 0 if tablePos < 0
		updateList tablePos

	$('.movies tbody').on(
		'click', 
		'tr',
		->
			$('.clickToDetail').hide()
			id = $(@).data('id')
			if $('.details:visible').length <= 0
				updateDetails id
				$('.details').show('drop')
			else
				$('.details').hide(
					'drop',
					->
						updateDetails id
						$('.details').show('drop')
				)

	)

	ascSort = (a, b) ->
		($(b).text()) < ($(a).text()) ? 1 : -1;

	$('.addToSelection').on(
		'click',
		->
			$('.selectionHint').hide()
			id = $('.id').html()
			if $(".selection li.id-#{id}").length <= 0
				$('.selection ul').append("<li class=\"id-#{id}\">#{$('.title').html()}</li>")
				$('.selection ul > li').sort(ascSort).appendTo('.selection ul')
	)

	updateList()