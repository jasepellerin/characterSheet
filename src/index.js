"use strict";

require("./styles/main.scss");

const { Elm } = require("./elm/Main");

var app = Elm.Main.init({});

console.log(Elm, app);

app.ports.toJs.subscribe(data => {
    console.log(data);
});

var testFn = inp => {
    let a = inp + 1;
    return a;
};
