function secondsToMinutes(time) {
    var self = this;

    time = Math.round(time);

    var hours = Math.floor(time / 60 / 60);
    var minutes = Math.floor(time / 60) - (hours * 60);
    var seconds = time % 60;

    if (hours > 0) {
        minutes += hours * 60;
    }

    return simplePadLeft(minutes, 2) + ':' + simplePadLeft(seconds, 2);
};

function secondsToFullHours(time) {
    var self = this;

    time = Math.round(time);

    var hours = Math.floor(time / 60 / 60);
    var minutes = Math.floor(time / 60) - (hours * 60);
    var seconds = time % 60;

    return simplePadLeft(hours, 2) + ':' + simplePadLeft(minutes, 2) + ':' + simplePadLeft(seconds, 2);
};

function simplePadLeft(i, length) {
    var str = '' + i;

    while (str.length < length) {
        str = '0' + str;
    }

    return str;
};


function minMax(v, min, max) {
    return (Math.min(max, Math.max(min, v)));
}

