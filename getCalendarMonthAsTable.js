/**
 * Get HTML for selected year+month
 *
 * @param int year
 * @param int month [0-11]
 * @returns string table
 */
function getCalendarMonthAsTable(year, month, options) {
    var day, i,
        firstDay = new Date(year, month, 1).getDay(),
        lastDate = new Date(year, month + 1, 0).getDate(),
        output = [],
        startDate = 1;

    options = $.extend({
        "firstDayOfWeek": 1, // Monday
        "showWeekDays": true,
        "weekDays": ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    }, options);

    startDate = startDate - (firstDay - options.firstDayOfWeek);

    if (startDate > 1) {
        startDate = startDate - 7;
    }

    var cell = 0, week = 0;
    for (day = startDate; day <= lastDate; day++, td++) {

        week = Math.floor(cell++ / 7);
        if (!output[week]) {
            output[week] = [];
        }
        if (day > 0) {
            output[week].push('<td data-date="' + getFullDateAsNumber(year, month, day) + '">' + day + '</td>');
        } else {
            output[week].push('<td></td>');
        }
    }
    for (i = 0; i < output.length; i++) {
        output[i] = '<tr>' + output[i].join('') + '</tr>';
    }

    if (options.showWeekDays) {
        output.head = [];
        for (i = 0; i < 7; i++) {
            output.head.push('<th>' + options.weekDays[(options.firstDayOfWeek + i) % 7] + '</th>');
        }
    }

    output.body = '<tbody>' + output.join('') + '</tbody>';
    output.head = output.head ? '<thead><tr>' + output.head.join('') + '</tr></thead>' : '';

    return '<table>' + output.head + output.body + '</table>';

    function getFullDateAsNumber(year, month, day) {
        var date = ('0000' + year).substr(-4) + ('00' + (month + 1)).substr(-2) + ('00' + day).substr(-2);
        return parseInt(date);
    }
}

getCalendarMonthAsTable(2015, 9);
