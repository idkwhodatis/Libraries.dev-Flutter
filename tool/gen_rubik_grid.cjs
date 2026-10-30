const fs=require('fs');
const pairs=[[4,12],[6,16],[9,24]];
let out='// GENERATED CODE - DO NOT MODIFY BY HAND.\n// JS Math base grid values for rubik parity.\n\nconst Map<String, List<List<double>>> kRubikGrids = {\n';
for(const [latRings,lonDensity] of pairs){
  out+=`  '${latRings}x${lonDensity}': [\n`;
  for(let li=0;li<=latRings;li++){
    const lat=-Math.PI/2+(li/latRings)*Math.PI;
    const cosLat=Math.cos(lat), sinLat=Math.sin(lat);
    const lonCount=Math.max(1,Math.round(Math.abs(cosLat)*lonDensity));
    for(let lj=0;lj<lonCount;lj++){
      const lon=(lj/lonCount)*2*Math.PI;
      out+=`    [${cosLat*Math.cos(lon)}, ${sinLat}, ${cosLat*Math.sin(lon)}],\n`;
    }
  }
  out+='  ],\n';
}
out+='};\n';
fs.writeFileSync('packages/thinking_orbs/lib/src/modes/rubik_grid.g.dart',out);
console.log(out.slice(0,600));
