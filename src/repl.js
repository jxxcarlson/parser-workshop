

const repl = require('repl');


// Link to Elm code
var Elm = require('./main').Elm;
var main = Elm.Main.init();

// Eval function for the repl
function eval(input, _, __, callback) {
  console.log ("Input: " + input)
  main.ports.put.subscribe(
    function putCallback (data) {
      main.ports.put.unsubscribe(putCallback)
      callback(null, data)
    }
  )
  main.ports.get.send(input)
}

function myWriter(output) {
  return output
}

console.log("\nParse markup\n")

repl.start({ prompt: '> ', eval: eval, writer: myWriter});