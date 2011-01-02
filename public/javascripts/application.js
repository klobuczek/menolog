$(document).ready(function() {
    $("#calendar").datepicker({
        onSelect: function(dateText, inst) {
            window.location = '/days?date=' + dateText;
        },
        changeYear: true,
        changeMonth: true,
        defaultDate: new Date($('#day_date').val())
    });
});

