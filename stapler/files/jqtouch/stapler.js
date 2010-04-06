/* staplr.js
 *
 */

var baseurl = "/";


function message(msg) {
    $("#message").text(msg);
}


function get_movement() {
    
    $.ajax({
        url: baseurl + "stapler/holen/",
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
    var url = baseurl + "stapler/zurueckmelden/";
    var params = {movement_id: localStorage.getItem("movement_id")};
    $.post(url, params, function(data) {
        if (data["status"] !=  "OK")
            alert ("Fehler beim Zurückmelden");
    }, 'json');
    alert('goto main!');
    jQT.goTo("#main", "slideup");
}

function cancel_movement() {
    var url = baseurl + "stapler/zurueckmelden/";
    var params = {
                    movement_id: localStorage.getItem("movement_id"),
                    storno: true
                 };
    $.post(url, params, function(data) {
        if (data["status"] !=  "OK") {
            alert ("Fehler beim Stornieren");
        }
    }, 'json');
    
    jQT.goTo("#main", "slideup");
}

function logged_in() {
    var result = undefined;
    $.ajax({
            async: false,
            dataType: 'json',
            url: baseurl + "stapler/home/",
            error: function(status, request) {
                result = false;
            },
            success: function(data, status, request) {
                result = true;
            }
        });
    return result;
}

function init() {
    if(logged_in()) {
        jQT.goTo("#main", "slideup");
    } else {
        jQT.goTo("#login", "slideup");
    }
}


function stapler_login() {
    var url = baseurl + 'accounts/login/';
    var params = {username : $("#username").val(),
                  password : $("#password").val(),
                  next: '/stapler/home/'
                 };
    
    $.post(url, params, function(data) {
        if(data["status"] == "OK") {
            localStorage.setItem('username', params.username);
            $("#user").text(localStorage.getItem("username"));
            jQT.goTo("#main", "slideup");
        } else {
            alert("Benutzername unbekannt oder Passwort falsch");
        }
    }, "json");
}

function stapler_logout() {
    var url = baseurl + "accounts/logout/";
    $.post(url, function(data){});
    localStorage.clear();
    jQT.goTo("#start", "slideup");
}
