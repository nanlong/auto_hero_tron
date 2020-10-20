const fs = require('fs');
const time = require('./time')


module.exports = function(network, buffer){
  let path = './deployed/' + network + '.json'
  let lastPath = path.substring(0, path.lastIndexOf("/"));
  let data = JSON.stringify(buffer, null, 2);

  fs.mkdir(lastPath, {recursive: true}, (err) => {
      if (err) console.error(err);

      fs.writeFile(path, data, function(err){
          if (err) console.error(err);
      });
  });
}