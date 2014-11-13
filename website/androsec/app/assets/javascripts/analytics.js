/**
 * Created by jacobpeterson on 11/4/14.
 */

var ready;
ready = function() {
    $('#analyticsTable').dataTable();

    $('#analyticsTable tbody').on('click', 'tr', function () {
        var appID = $('td', this).eq(0).text();
        window.location = '/analytics/' + appID;
    } );
};

$(document).ready(ready);
$(document).on('page:load', ready);