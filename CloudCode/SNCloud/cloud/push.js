Parse.Cloud.define('sendPushToYourself', function (request, response) {
    var currentUser = request.user;
    var userId = currentUser.id;

    var query = new Parse.Query("Installation");
    query.equalTo("userId", userId);
    query.descending("updatedAt");
    Parse.Push.send({
        where: query,
        data: {
            title: "Hello from the Cloud Code",
            alert: "Back4App rocks! Single Message!",
        }
    }, {
        useMasterKey: true,
        success: function () {
            response.success("success sending a single push!");
        },
        error: function (error) {
            response.error(error.code + " : " + error.description);
        }
    });
});

Parse.Cloud.define('sendPushToAllUsers', function (request, response) {
    var currentUser = request.user;
    var userIds = [currentUser.id];

    var query = new Parse.Query(Parse.Installation);
    query.containedIn('userId', userIds);
    Parse.Push.send({
        where: query,
        data: {
            title: "Hello from the Cloud Code",
            alert: "Back4App rocks! Group Message!",
        }
    }, {
        useMasterKey: true,
        success: function () {
            response.success('Success sending a group push!');
        },
        error: function (message) {
            response.error(error.code + " : " + error.description);
        }
    });
});