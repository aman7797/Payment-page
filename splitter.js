const BUNDLE_SRC = "dist/bundle.js";
const LIB_SRC    = "dist/lib.js";
const SRC_SRC    = "dist/src.js";

var acorn = require('acorn-node');
var fs    = require('fs');
var cp    = require('child_process');

var walkSync = function(dir, filelist) {
  var files    = fs.readdirSync(dir);
  var filelist = filelist || [];
  files.forEach(function(file) {
    if (fs.statSync(dir + file).isDirectory()) {
      filelist = walkSync(dir + file + '/', filelist);
    }
    else {
      filelist.push(dir + file);
    }
  });
  return filelist;
};

var pursModule = function(fileName) {
  var content  = cp.execSync("cat " + fileName + " | grep \"module.*\"");
  return content.toString().split(' ')[1].replace('\\n', '').trim();
}

console.log("extracting lib modules...");
var lib = walkSync("bower_components/")
            .filter((f) => f.endsWith(".purs"))
            .map((f) => pursModule(f));

console.log("extracting src modules...");
var src = walkSync("src/")
            .filter((f) => f.endsWith(".purs"))
            .map((f) => pursModule(f));


console.log("creating ast for " + BUNDLE_SRC + "...")
var bundle    = fs.readFileSync(BUNDLE_SRC);
var astTree   = acorn.parse(bundle.toString());
var libBlocks = [];
var srcBlocks = [];

console.log("analysing code blocks...")
for(var i in astTree.body) {
  var node = astTree.body[i];
  var temp = bundle.slice(node.start, node.end)

  if(node.type != "ExpressionStatement") {
    if(temp.toString() == "var PS = {};") {
      libBlocks.push(Buffer.from("window.PS = {};"));
    } else {
      libBlocks.push(temp);
    }
  } else {
    var child = node.expression;
    switch(child.type) {
      case "CallExpression":
        if(child.callee.type != "FunctionExpression") {
          // PS["Main"].main();
          if(child.callee.type == "MemberExpression") {
            var module = child.callee.object.property.value;
            if(src.findIndex(i => i == module) != -1) {
              srcBlocks.push(temp);
            } else {
              libBlocks.push(temp);
            }
          } else {
            throw new Error("Unknown Format in purs bundle");
          }
        } else {
          if(child.arguments.length == 1 && child.arguments[0].type == "AssignmentExpression") {
            var args = child.arguments[0];
            var module = args.left.property.value;
            if(src.findIndex(i => i == module) != -1) {
              srcBlocks.push(temp);
            } else {
              libBlocks.push(temp);
            }
          } else {
            throw new Error("Unknown Format in purs bundle");
          }
        }
        break;
      default:
        console.log(temp.toString())
        throw new Error("this is new")
    }
  }
}

var writeToFile = function(file, content) {
  fs.appendFileSync(file, content);
  fs.appendFileSync(file, "\n");
}

console.log("writing lib to " + LIB_SRC + "...");
try { fs.unlinkSync(LIB_SRC); } catch(err) {}
libBlocks.forEach(i => writeToFile(LIB_SRC, i));

console.log("writing src to " + SRC_SRC + "...");
try { fs.unlinkSync(SRC_SRC); } catch(err) {}
srcBlocks.forEach(i => writeToFile(SRC_SRC, i));

console.log("Split Successful!");
