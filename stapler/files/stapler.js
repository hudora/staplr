/* staplr.js
 *
 */

var BASE_URL = "/";

$(document).ready(function() {
    if(logged_in() == false) {
        jQT.goTo("#login", "slideup");
    }
});

function get_movement() {
    $.ajax({
        url: BASE_URL + "stapler/holen/",
        dataType: "json",
        type: "POST",
        error: function(status, request) {
            alert("Keine Umlagerung verfügbar");
        },
        success: function(data, status) {
            movement = data;
            $("#movement_source").text(movement.from_location);
            $("#movement_destination").text(movement.to_location);
            $("#movement_artnr").text(movement.artnr);
            $("#movement_quantity").text(movement.menge);
            localStorage.setItem('movement_id', movement.oid);
        }
    });
}

function commit_movement() {
    var url = BASE_URL + "stapler/zurueckmelden/";
    var params = {movement_id: localStorage.getItem("movement_id")};
    $.post(url, params, function(data) {
        if (data["status"] !=  "OK")
            alert ("Fehler beim Zurückmelden");
    }, 'json');
    jQT.goTo("#home", "slideup");
}

function cancel_movement() {
    var url = BASE_URL + "stapler/zurueckmelden/";
    var params = {
                    movement_id: localStorage.getItem("movement_id"),
                    storno: true
                 };
    $.post(url, params, function(data) {
        if (data["status"] !=  "OK") {
            alert ("Fehler beim Stornieren");
        }
    }, 'json');
    
    jQT.goTo("#home", "slideup");
}

function logged_in() {
    var result = undefined;
    $.ajax({
            async: false,
            dataType: 'json',
            url: BASE_URL + "stapler/home/",
            error: function(status, request) {
                $("#user").text("Nicht angemeldet");
                result = false;
            },
            success: function(data, status, request) {
                $("#user").text("Angemeldet als " + data["username"]);
                result = true;
            }
        });
    console.log("logged in: " + result);
    return result;
}

function stapler_login() {
    var url = BASE_URL + 'accounts/login/';
    var params = {username : $("#username").val(),
                  password : $("#password").val(),
                  next: '/stapler/home/'
                 };
    
    $.ajax({
        async: false,
        url: url,
        data: params,
        dataType: "json",
        type: "POST",
        error: function(status, request) {
            alert("Benutzername unbekannt oder Passwort falsch");
        },
        success: function(data, status) {
            alert("OK! GOTO #HOME")
            jQT.goTo("#home", "slideup");
        }
    });
}

function stapler_logout() {
    var url = BASE_URL + "accounts/logout/";
    $.post(url, function(data){});
    localStorage.clear();
    jQT.goTo("#login", "slideup");
}
