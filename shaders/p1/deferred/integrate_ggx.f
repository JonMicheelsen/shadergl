#define P1_SHADERS
#include <common.fh>

vec2 good_blue_noise(vec2 coord)
{
    int i = int(mod(coord.x, 16.0));
    int j = int(mod(coord.y, 16.0));
    int finalDist = j*16+i;
    
    if(finalDist < 128) 
{
if(finalDist < 64) 
{
if(finalDist < 32) 
{
if(finalDist < 16) 
{
if(finalDist < 8) 
{
if(finalDist < 4) 
{
if(finalDist < 2) 
{
if(finalDist < 1) 
{
return vec2(0.332031, 0.707031);} else {
return vec2(0.652344, 0.972656);
}} else {
if(finalDist < 3) 
{
return vec2(0.457031, 0.5);} else {
return vec2(0.175781, 0.953125);
}
}} else {
if(finalDist < 6) 
{
if(finalDist < 5) 
{
return vec2(0.417969, 0.316406);} else {
return vec2(0.398438, 0.609375);
}} else {
if(finalDist < 7) 
{
return vec2(0.660156, 0.769531);} else {
return vec2(0.960938, 0.804688);
}
}
}} else {
if(finalDist < 12) 
{
if(finalDist < 10) 
{
if(finalDist < 9) 
{
return vec2(0.3125, 0.25);} else {
return vec2(0.285156, 0.09375);
}} else {
if(finalDist < 11) 
{
return vec2(0, 0.851563);} else {
return vec2(0.921875, 0.273438);
}
}} else {
if(finalDist < 14) 
{
if(finalDist < 13) 
{
return vec2(0.351563, 0.652344);} else {
return vec2(0.167969, 0.738281);
}} else {
if(finalDist < 15) 
{
return vec2(0.195313, 0.203125);} else {
return vec2(0.90625, 0.808594);
}
}
}
}} else {
if(finalDist < 24) 
{
if(finalDist < 20) 
{
if(finalDist < 18) 
{
if(finalDist < 17) 
{
return vec2(0.203125, 0.0664063);} else {
return vec2(0.839844, 0.160156);
}} else {
if(finalDist < 19) 
{
return vec2(0.867188, 0.40625);} else {
return vec2(0.257813, 0.472656);
}
}} else {
if(finalDist < 22) 
{
if(finalDist < 21) 
{
return vec2(0.785156, 0.164063);} else {
return vec2(0.542969, 0.351563);
}} else {
if(finalDist < 23) 
{
return vec2(0.0664063, 0.863281);} else {
return vec2(0.597656, 0.15625);
}
}
}} else {
if(finalDist < 28) 
{
if(finalDist < 26) 
{
if(finalDist < 25) 
{
return vec2(0.0195313, 0.8125);} else {
return vec2(0.6875, 0.601563);
}} else {
if(finalDist < 27) 
{
return vec2(0.582031, 0.75);} else {
return vec2(0.765625, 0.0898438);
}
}} else {
if(finalDist < 30) 
{
if(finalDist < 29) 
{
return vec2(0.304688, 0.242188);} else {
return vec2(0.574219, 0.65625);
}} else {
if(finalDist < 31) 
{
return vec2(0.773438, 0.214844);} else {
return vec2(0.128906, 0.886719);
}
}
}
}
}} else {
if(finalDist < 48) 
{
if(finalDist < 40) 
{
if(finalDist < 36) 
{
if(finalDist < 34) 
{
if(finalDist < 33) 
{
return vec2(0.4375, 0.296875);} else {
return vec2(0.511719, 0.871094);
}} else {
if(finalDist < 35) 
{
return vec2(0.0390625, 0.308594);} else {
return vec2(0.539063, 0.632813);
}
}} else {
if(finalDist < 38) 
{
if(finalDist < 37) 
{
return vec2(0.863281, 0.933594);} else {
return vec2(0.0429688, 0.28125);
}} else {
if(finalDist < 39) 
{
return vec2(0.828125, 0.683594);} else {
return vec2(0.585938, 0.261719);
}
}
}} else {
if(finalDist < 44) 
{
if(finalDist < 42) 
{
if(finalDist < 41) 
{
return vec2(0.847656, 0.570313);} else {
return vec2(0.769531, 0.121094);
}} else {
if(finalDist < 43) 
{
return vec2(0.0859375, 0.410156);} else {
return vec2(0.933594, 0.910156);
}
}} else {
if(finalDist < 46) 
{
if(finalDist < 45) 
{
return vec2(0.0078125, 0.894531);} else {
return vec2(0.898438, 0.695313);
}} else {
if(finalDist < 47) 
{
return vec2(0.117188, 0.480469);} else {
return vec2(0.914063, 0.511719);
}
}
}
}} else {
if(finalDist < 56) 
{
if(finalDist < 52) 
{
if(finalDist < 50) 
{
if(finalDist < 49) 
{
return vec2(0.246094, 0.976563);} else {
return vec2(0.746094, 0.367188);
}} else {
if(finalDist < 51) 
{
return vec2(0.566406, 0.304688);} else {
return vec2(0.105469, 0.785156);
}
}} else {
if(finalDist < 54) 
{
if(finalDist < 53) 
{
return vec2(0.722656, 0.238281);} else {
return vec2(0.761719, 0.0234375);
}} else {
if(finalDist < 55) 
{
return vec2(0.382813, 0.832031);} else {
return vec2(0.28125, 0.0273438);
}
}
}} else {
if(finalDist < 60) 
{
if(finalDist < 58) 
{
if(finalDist < 57) 
{
return vec2(0.234375, 0.699219);} else {
return vec2(0.378906, 0.585938);
}} else {
if(finalDist < 59) 
{
return vec2(0.421875, 0.636719);} else {
return vec2(0.613281, 0.378906);
}
}} else {
if(finalDist < 62) 
{
if(finalDist < 61) 
{
return vec2(0.441406, 0.195313);} else {
return vec2(0.519531, 0.171875);
}} else {
if(finalDist < 63) 
{
return vec2(0.390625, 0.859375);} else {
return vec2(0.628906, 0.421875);
}
}
}
}
}
}} else {
if(finalDist < 96) 
{
if(finalDist < 80) 
{
if(finalDist < 72) 
{
if(finalDist < 68) 
{
if(finalDist < 66) 
{
if(finalDist < 65) 
{
return vec2(0.835938, 0.417969);} else {
return vec2(0.140625, 0.375);
}} else {
if(finalDist < 67) 
{
return vec2(0.96875, 0.84375);} else {
return vec2(0.136719, 0.257813);
}
}} else {
if(finalDist < 70) 
{
if(finalDist < 69) 
{
return vec2(0.335938, 0.90625);} else {
return vec2(0.65625, 0.664063);
}} else {
if(finalDist < 71) 
{
return vec2(0.273438, 0.539063);} else {
return vec2(0.59375, 0.824219);
}
}
}} else {
if(finalDist < 76) 
{
if(finalDist < 74) 
{
if(finalDist < 73) 
{
return vec2(0.917969, 0.800781);} else {
return vec2(0.832031, 0.136719);
}} else {
if(finalDist < 75) 
{
return vec2(0.144531, 0.0117188);} else {
return vec2(0.667969, 0.925781);
}
}} else {
if(finalDist < 78) 
{
if(finalDist < 77) 
{
return vec2(0.101563, 0.449219);} else {
return vec2(0.742188, 0.675781);
}} else {
if(finalDist < 79) 
{
return vec2(0.75, 0.0429688);} else {
return vec2(0.0820313, 0.246094);
}
}
}
}} else {
if(finalDist < 88) 
{
if(finalDist < 84) 
{
if(finalDist < 82) 
{
if(finalDist < 81) 
{
return vec2(0.179688, 0.914063);} else {
return vec2(0.664063, 0.0351563);
}} else {
if(finalDist < 83) 
{
return vec2(0.480469, 0.789063);} else {
return vec2(0.734375, 0.105469);
}
}} else {
if(finalDist < 86) 
{
if(finalDist < 85) 
{
return vec2(0.753906, 0.390625);} else {
return vec2(0.183594, 0.484375);
}} else {
if(finalDist < 87) 
{
return vec2(0.691406, 0.109375);} else {
return vec2(0.359375, 0.175781);
}
}
}} else {
if(finalDist < 92) 
{
if(finalDist < 90) 
{
if(finalDist < 89) 
{
return vec2(0.0625, 0.726563);} else {
return vec2(0.425781, 0.648438);
}} else {
if(finalDist < 91) 
{
return vec2(0.449219, 0.761719);} else {
return vec2(0.699219, 0.113281);
}
}} else {
if(finalDist < 94) 
{
if(finalDist < 93) 
{
return vec2(0.820313, 0.558594);} else {
return vec2(0.0976563, 0.71875);
}} else {
if(finalDist < 95) 
{
return vec2(0.609375, 0.523438);} else {
return vec2(0.476563, 0.671875);
}
}
}
}
}} else {
if(finalDist < 112) 
{
if(finalDist < 104) 
{
if(finalDist < 100) 
{
if(finalDist < 98) 
{
if(finalDist < 97) 
{
return vec2(0.878906, 0.773438);} else {
return vec2(0.191406, 0.269531);
}} else {
if(finalDist < 99) 
{
return vec2(0.472656, 0.667969);} else {
return vec2(0.0234375, 0.566406);
}
}} else {
if(finalDist < 102) 
{
if(finalDist < 101) 
{
return vec2(0.78125, 0.898438);} else {
return vec2(0.078125, 0.535156);
}} else {
if(finalDist < 103) 
{
return vec2(0.851563, 0.875);} else {
return vec2(0.925781, 0.292969);
}
}
}} else {
if(finalDist < 108) 
{
if(finalDist < 106) 
{
if(finalDist < 105) 
{
return vec2(0.796875, 0.613281);} else {
return vec2(0.355469, 0.148438);
}} else {
if(finalDist < 107) 
{
return vec2(0.957031, 0.222656);} else {
return vec2(0.046875, 0.730469);
}
}} else {
if(finalDist < 110) 
{
if(finalDist < 109) 
{
return vec2(0.394531, 0.714844);} else {
return vec2(0.484375, 0.015625);
}} else {
if(finalDist < 111) 
{
return vec2(0.816406, 0.78125);} else {
return vec2(0.0585938, 0.132813);
}
}
}
}} else {
if(finalDist < 120) 
{
if(finalDist < 116) 
{
if(finalDist < 114) 
{
if(finalDist < 113) 
{
return vec2(0.984375, 0.140625);} else {
return vec2(0.679688, 0.425781);
}} else {
if(finalDist < 115) 
{
return vec2(0.671875, 0.980469);} else {
return vec2(0.347656, 0.03125);
}
}} else {
if(finalDist < 118) 
{
if(finalDist < 117) 
{
return vec2(0.941406, 0.199219);} else {
return vec2(0.632813, 0.46875);
}} else {
if(finalDist < 119) 
{
return vec2(0.160156, 0.234375);} else {
return vec2(0.261719, 0.890625);
}
}
}} else {
if(finalDist < 124) 
{
if(finalDist < 122) 
{
if(finalDist < 121) 
{
return vec2(0.277344, 0.355469);} else {
return vec2(0.367188, 0.597656);
}} else {
if(finalDist < 123) 
{
return vec2(0.328125, 0.488281);} else {
return vec2(0.996094, 0.996094);
}
}} else {
if(finalDist < 126) 
{
if(finalDist < 125) 
{
return vec2(0.578125, 0.183594);} else {
return vec2(0.929688, 0.515625);
}} else {
if(finalDist < 127) 
{
return vec2(0.0117188, 0.988281);} else {
return vec2(0.527344, 0.503906);
}
}
}
}
}
}
}} else {
if(finalDist < 192) 
{
if(finalDist < 160) 
{
if(finalDist < 144) 
{
if(finalDist < 136) 
{
if(finalDist < 132) 
{
if(finalDist < 130) 
{
if(finalDist < 129) 
{
return vec2(0.210938, 0.835938);} else {
return vec2(0.714844, 0.3125);
}} else {
if(finalDist < 131) 
{
return vec2(0.164063, 0.492188);} else {
return vec2(0.25, 0.589844);
}
}} else {
if(finalDist < 134) 
{
if(finalDist < 133) 
{
return vec2(0.601563, 0.53125);} else {
return vec2(0.226563, 0.949219);
}} else {
if(finalDist < 135) 
{
return vec2(0.757813, 0.117188);} else {
return vec2(0.46875, 0.527344);
}
}
}} else {
if(finalDist < 140) 
{
if(finalDist < 138) 
{
if(finalDist < 137) 
{
return vec2(0.703125, 0.703125);} else {
return vec2(0.675781, 0.992188);
}} else {
if(finalDist < 139) 
{
return vec2(0.265625, 0.046875);} else {
return vec2(0.40625, 0.550781);
}
}} else {
if(finalDist < 142) 
{
if(finalDist < 141) 
{
return vec2(0.292969, 0.542969);} else {
return vec2(0.222656, 0.0390625);
}} else {
if(finalDist < 143) 
{
return vec2(0.617188, 0.429688);} else {
return vec2(0.34375, 0.359375);
}
}
}
}} else {
if(finalDist < 152) 
{
if(finalDist < 148) 
{
if(finalDist < 146) 
{
if(finalDist < 145) 
{
return vec2(0.433594, 0.0195313);} else {
return vec2(0.113281, 0.757813);
}} else {
if(finalDist < 147) 
{
return vec2(0.945313, 0.679688);} else {
return vec2(0.414063, 0.078125);
}
}} else {
if(finalDist < 150) 
{
if(finalDist < 149) 
{
return vec2(0.695313, 0.582031);} else {
return vec2(0.0703125, 0.691406);
}} else {
if(finalDist < 151) 
{
return vec2(0.648438, 0.460938);} else {
return vec2(0.015625, 0.125);
}
}
}} else {
if(finalDist < 156) 
{
if(finalDist < 154) 
{
if(finalDist < 153) 
{
return vec2(0.9375, 0.00390625);} else {
return vec2(0.1875, 0.644531);
}} else {
if(finalDist < 155) 
{
return vec2(0.824219, 0.285156);} else {
return vec2(0.546875, 0.6875);
}
}} else {
if(finalDist < 158) 
{
if(finalDist < 157) 
{
return vec2(0.972656, 0.128906);} else {
return vec2(0.53125, 0.9375);
}} else {
if(finalDist < 159) 
{
return vec2(0.371094, 0.753906);} else {
return vec2(0.882813, 0.382813);
}
}
}
}
}} else {
if(finalDist < 176) 
{
if(finalDist < 168) 
{
if(finalDist < 164) 
{
if(finalDist < 162) 
{
if(finalDist < 161) 
{
return vec2(0.21875, 0.457031);} else {
return vec2(0.492188, 0.855469);
}} else {
if(finalDist < 163) 
{
return vec2(0.789063, 0.339844);} else {
return vec2(0.152344, 0.1875);
}
}} else {
if(finalDist < 166) 
{
if(finalDist < 165) 
{
return vec2(0.683594, 0.960938);} else {
return vec2(0.621094, 0.347656);
}} else {
if(finalDist < 167) 
{
return vec2(0.644531, 0.839844);} else {
return vec2(0.992188, 0.605469);
}
}
}} else {
if(finalDist < 172) 
{
if(finalDist < 170) 
{
if(finalDist < 169) 
{
return vec2(0.535156, 0.945313);} else {
return vec2(0.15625, 0.394531);
}} else {
if(finalDist < 171) 
{
return vec2(0.792969, 0.371094);} else {
return vec2(0.121094, 0.984375);
}
}} else {
if(finalDist < 174) 
{
if(finalDist < 173) 
{
return vec2(0.605469, 0.496094);} else {
return vec2(0.0273438, 0.191406);
}} else {
if(finalDist < 175) 
{
return vec2(0.464844, 0.277344);} else {
return vec2(0.777344, 0.929688);
}
}
}
}} else {
if(finalDist < 184) 
{
if(finalDist < 180) 
{
if(finalDist < 178) 
{
if(finalDist < 177) 
{
return vec2(0.964844, 0.0976563);} else {
return vec2(0.515625, 0.34375);
}} else {
if(finalDist < 179) 
{
return vec2(0.730469, 0.621094);} else {
return vec2(0.09375, 0.902344);
}
}} else {
if(finalDist < 182) 
{
if(finalDist < 181) 
{
return vec2(0.988281, 0);} else {
return vec2(0.386719, 0.328125);
}} else {
if(finalDist < 183) 
{
return vec2(0.320313, 0.0625);} else {
return vec2(0.132813, 0.660156);
}
}
}} else {
if(finalDist < 188) 
{
if(finalDist < 186) 
{
if(finalDist < 185) 
{
return vec2(0.300781, 0.476563);} else {
return vec2(0.558594, 0.324219);
}} else {
if(finalDist < 187) 
{
return vec2(0.554688, 0.5625);} else {
return vec2(0.0507813, 0.101563);
}
}} else {
if(finalDist < 190) 
{
if(finalDist < 189) 
{
return vec2(0.625, 0.519531);} else {
return vec2(0.636719, 0.816406);
}} else {
if(finalDist < 191) 
{
return vec2(0.890625, 0.386719);} else {
return vec2(0.0351563, 0.578125);
}
}
}
}
}
}} else {
if(finalDist < 224) 
{
if(finalDist < 208) 
{
if(finalDist < 200) 
{
if(finalDist < 196) 
{
if(finalDist < 194) 
{
if(finalDist < 193) 
{
return vec2(0.375, 0.964844);} else {
return vec2(0.253906, 0.210938);
}} else {
if(finalDist < 195) 
{
return vec2(0.402344, 0.402344);} else {
return vec2(0.726563, 0.792969);
}
}} else {
if(finalDist < 198) 
{
if(finalDist < 197) 
{
return vec2(0.207031, 0.507813);} else {
return vec2(0.871094, 0.722656);
}} else {
if(finalDist < 199) 
{
return vec2(0.503906, 0.867188);} else {
return vec2(0.507813, 0.21875);
}
}
}} else {
if(finalDist < 204) 
{
if(finalDist < 202) 
{
if(finalDist < 201) 
{
return vec2(0.738281, 0.144531);} else {
return vec2(0.902344, 0.847656);
}} else {
if(finalDist < 203) 
{
return vec2(0.5, 0.957031);} else {
return vec2(0.238281, 0.253906);
}
}} else {
if(finalDist < 206) 
{
if(finalDist < 205) 
{
return vec2(0.8125, 0.179688);} else {
return vec2(0.0898438, 0.414063);
}} else {
if(finalDist < 207) 
{
return vec2(0.460938, 0.734375);} else {
return vec2(0.488281, 0.0703125);
}
}
}
}} else {
if(finalDist < 216) 
{
if(finalDist < 212) 
{
if(finalDist < 210) 
{
if(finalDist < 209) 
{
return vec2(0.707031, 0.828125);} else {
return vec2(0.976563, 0.554688);
}} else {
if(finalDist < 211) 
{
return vec2(0.0546875, 0.628906);} else {
return vec2(0.523438, 0.0820313);
}
}} else {
if(finalDist < 214) 
{
if(finalDist < 213) 
{
return vec2(0.148438, 0.335938);} else {
return vec2(0.589844, 0.363281);
}} else {
if(finalDist < 215) 
{
return vec2(0.0742188, 0.746094);} else {
return vec2(0.980469, 0.777344);
}
}
}} else {
if(finalDist < 220) 
{
if(finalDist < 218) 
{
if(finalDist < 217) 
{
return vec2(0.242188, 0.332031);} else {
return vec2(0.125, 0.625);
}} else {
if(finalDist < 219) 
{
return vec2(0.949219, 0.207031);} else {
return vec2(0.363281, 0.796875);
}
}} else {
if(finalDist < 222) 
{
if(finalDist < 221) 
{
return vec2(0.894531, 0.320313);} else {
return vec2(0.410156, 0.96875);
}} else {
if(finalDist < 223) 
{
return vec2(0.859375, 0.441406);} else {
return vec2(0.199219, 0.0859375);
}
}
}
}
}} else {
if(finalDist < 240) 
{
if(finalDist < 232) 
{
if(finalDist < 228) 
{
if(finalDist < 226) 
{
if(finalDist < 225) 
{
return vec2(0.289063, 0.433594);} else {
return vec2(0.84375, 0.0546875);
}} else {
if(finalDist < 227) 
{
return vec2(0.429688, 0.941406);} else {
return vec2(0.953125, 0.640625);
}
}} else {
if(finalDist < 230) 
{
if(finalDist < 229) 
{
return vec2(0.324219, 0.878906);} else {
return vec2(0.875, 0.230469);
}} else {
if(finalDist < 231) 
{
return vec2(0.269531, 0.453125);} else {
return vec2(0.445313, 0.917969);
}
}
}} else {
if(finalDist < 236) 
{
if(finalDist < 234) 
{
if(finalDist < 233) 
{
return vec2(0.910156, 0.0742188);} else {
return vec2(0.339844, 0.546875);
}} else {
if(finalDist < 235) 
{
return vec2(0.230469, 0.0507813);} else {
return vec2(0.214844, 0.574219);
}
}} else {
if(finalDist < 238) 
{
if(finalDist < 237) 
{
return vec2(0.804688, 0.710938);} else {
return vec2(0.171875, 0.167969);
}} else {
if(finalDist < 239) 
{
return vec2(0.109375, 0.882813);} else {
return vec2(0.550781, 0.742188);
}
}
}
}} else {
if(finalDist < 248) 
{
if(finalDist < 244) 
{
if(finalDist < 242) 
{
if(finalDist < 241) 
{
return vec2(0.453125, 0.4375);} else {
return vec2(0.00390625, 0.300781);
}} else {
if(finalDist < 243) 
{
return vec2(0.71875, 0.445313);} else {
return vec2(0.308594, 0.0078125);
}
}} else {
if(finalDist < 246) 
{
if(finalDist < 245) 
{
return vec2(0.570313, 0.921875);} else {
return vec2(0.855469, 0.152344);
}} else {
if(finalDist < 247) 
{
return vec2(0.03125, 0.226563);} else {
return vec2(0.5625, 0.289063);
}
}
}} else {
if(finalDist < 252) 
{
if(finalDist < 250) 
{
if(finalDist < 249) 
{
return vec2(0.316406, 0.765625);} else {
return vec2(0.886719, 0.59375);
}} else {
if(finalDist < 251) 
{
return vec2(0.710938, 0.617188);} else {
return vec2(0.496094, 0.820313);
}
}} else {
if(finalDist < 254) 
{
if(finalDist < 253) 
{
return vec2(0.296875, 0.0585938);} else {
return vec2(0.808594, 0.464844);
}} else {
if(finalDist < 255) 
{
return vec2(0.800781, 0.398438);} else {
return vec2(0.640625, 0.265625);
}
}
}
}
}
}
}
}
return vec2(0.0);
}

float randBlue(vec2 coord)
{
    int i = int(mod(coord.x, 16.0));
    int j = int(mod(coord.y, 16.0));
    int finalDist = j*16+i;

if(finalDist < 128) 
{
if(finalDist < 64) 
{
if(finalDist < 32) 
{
if(finalDist < 16) 
{
if(finalDist < 8) 
{
if(finalDist < 4) 
{
if(finalDist < 2) 
{
if(finalDist < 1) 
{
return 0.28125;} else {
return 0.136719;
}} else {
if(finalDist < 3) 
{
return 0.433594;} else {
return 0.03125;
}
}} else {
if(finalDist < 6) 
{
if(finalDist < 5) 
{
return 0.550781;} else {
return 0.15625;
}} else {
if(finalDist < 7) 
{
return 0.714844;} else {
return 0.222656;
}
}
}} else {
if(finalDist < 12) 
{
if(finalDist < 10) 
{
if(finalDist < 9) 
{
return 0.835938;} else {
return 0.488281;
}} else {
if(finalDist < 11) 
{
return 0.792969;} else {
return 0.390625;
}
}} else {
if(finalDist < 14) 
{
if(finalDist < 13) 
{
return 0.878906;} else {
return 0.65625;
}} else {
if(finalDist < 15) 
{
return 0.117188;} else {
return 0.542969;
}
}
}
}} else {
if(finalDist < 24) 
{
if(finalDist < 20) 
{
if(finalDist < 18) 
{
if(finalDist < 17) 
{
return 0.203125;} else {
return 0.511719;
}} else {
if(finalDist < 19) 
{
return 0.925781;} else {
return 0.296875;
}
}} else {
if(finalDist < 22) 
{
if(finalDist < 21) 
{
return 0.746094;} else {
return 0.480469;
}} else {
if(finalDist < 23) 
{
return 0.988281;} else {
return 0.382813;
}
}
}} else {
if(finalDist < 28) 
{
if(finalDist < 26) 
{
if(finalDist < 25) 
{
return 0.628906;} else {
return 0.300781;
}} else {
if(finalDist < 27) 
{
return 0.984375;} else {
return 0.0898438;
}
}} else {
if(finalDist < 30) 
{
if(finalDist < 29) 
{
return 0.1875;} else {
return 0.484375;
}} else {
if(finalDist < 31) 
{
return 0.960938;} else {
return 0.859375;
}
}
}
}
}} else {
if(finalDist < 48) 
{
if(finalDist < 40) 
{
if(finalDist < 36) 
{
if(finalDist < 34) 
{
if(finalDist < 33) 
{
return 0.675781;} else {
return 0.753906;
}} else {
if(finalDist < 35) 
{
return 0.101563;} else {
return 0.617188;
}
}} else {
if(finalDist < 38) 
{
if(finalDist < 37) 
{
return 0.882813;} else {
return 0.351563;
}} else {
if(finalDist < 39) 
{
return 0.0625;} else {
return 0.578125;
}
}
}} else {
if(finalDist < 44) 
{
if(finalDist < 42) 
{
if(finalDist < 41) 
{
return 0.875;} else {
return 0.152344;
}} else {
if(finalDist < 43) 
{
return 0.722656;} else {
return 0.472656;
}
}} else {
if(finalDist < 46) 
{
if(finalDist < 45) 
{
return 0.6875;} else {
return 0.289063;
}} else {
if(finalDist < 47) 
{
return 0.0078125;} else {
return 0.445313;
}
}
}
}} else {
if(finalDist < 56) 
{
if(finalDist < 52) 
{
if(finalDist < 50) 
{
if(finalDist < 49) 
{
return 0.332031;} else {
return 0.839844;
}} else {
if(finalDist < 51) 
{
return 0.527344;} else {
return 0.40625;
}
}} else {
if(finalDist < 54) 
{
if(finalDist < 53) 
{
return 0.121094;} else {
return 0.699219;
}} else {
if(finalDist < 55) 
{
return 0.21875;} else {
return 0.765625;
}
}
}} else {
if(finalDist < 60) 
{
if(finalDist < 58) 
{
if(finalDist < 57) 
{
return 0.0195313;} else {
return 0.234375;
}} else {
if(finalDist < 59) 
{
return 0.585938;} else {
return 0.261719;
}
}} else {
if(finalDist < 62) 
{
if(finalDist < 61) 
{
return 0.921875;} else {
return 0.8125;
}} else {
if(finalDist < 63) 
{
return 0.539063;} else {
return 0.132813;
}
}
}
}
}
}} else {
if(finalDist < 96) 
{
if(finalDist < 80) 
{
if(finalDist < 72) 
{
if(finalDist < 68) 
{
if(finalDist < 66) 
{
if(finalDist < 65) 
{
return 0.96875;} else {
return 0.0390625;
}} else {
if(finalDist < 67) 
{
return 0.207031;} else {
return 0.941406;
}
}} else {
if(finalDist < 70) 
{
if(finalDist < 69) 
{
return 0.285156;} else {
return 0.828125;
}} else {
if(finalDist < 71) 
{
return 0.652344;} else {
return 0.359375;
}
}
}} else {
if(finalDist < 76) 
{
if(finalDist < 74) 
{
if(finalDist < 73) 
{
return 0.523438;} else {
return 0.9375;
}} else {
if(finalDist < 75) 
{
return 0.785156;} else {
return 0.386719;
}
}} else {
if(finalDist < 78) 
{
if(finalDist < 77) 
{
return 0.0351563;} else {
return 0.726563;
}} else {
if(finalDist < 79) 
{
return 0.378906;} else {
return 0.644531;
}
}
}
}} else {
if(finalDist < 88) 
{
if(finalDist < 84) 
{
if(finalDist < 82) 
{
if(finalDist < 81) 
{
return 0.402344;} else {
return 0.71875;
}} else {
if(finalDist < 83) 
{
return 0.601563;} else {
return 0.742188;
}
}} else {
if(finalDist < 86) 
{
if(finalDist < 85) 
{
return 0.441406;} else {
return 0.046875;
}} else {
if(finalDist < 87) 
{
return 0.46875;} else {
return 0.160156;
}
}
}} else {
if(finalDist < 92) 
{
if(finalDist < 90) 
{
if(finalDist < 89) 
{
return 0.824219;} else {
return 0.292969;
}} else {
if(finalDist < 91) 
{
return 0.492188;} else {
return 0.125;
}
}} else {
if(finalDist < 94) 
{
if(finalDist < 93) 
{
return 0.613281;} else {
return 0.183594;
}} else {
if(finalDist < 95) 
{
return 0.910156;} else {
return 0.25;
}
}
}
}
}} else {
if(finalDist < 112) 
{
if(finalDist < 104) 
{
if(finalDist < 100) 
{
if(finalDist < 98) 
{
if(finalDist < 97) 
{
return 0.078125;} else {
return 0.871094;
}} else {
if(finalDist < 99) 
{
return 0.257813;} else {
return 0.535156;
}
}} else {
if(finalDist < 102) 
{
if(finalDist < 101) 
{
return 0.105469;} else {
return 0.972656;
}} else {
if(finalDist < 103) 
{
return 0.582031;} else {
return 0.914063;
}
}
}} else {
if(finalDist < 108) 
{
if(finalDist < 106) 
{
if(finalDist < 105) 
{
return 0.671875;} else {
return 0.0664063;
}} else {
if(finalDist < 107) 
{
return 0.730469;} else {
return 0.976563;
}
}} else {
if(finalDist < 110) 
{
if(finalDist < 109) 
{
return 0.308594;} else {
return 0.851563;
}} else {
if(finalDist < 111) 
{
return 0.453125;} else {
return 0.554688;
}
}
}
}} else {
if(finalDist < 120) 
{
if(finalDist < 116) 
{
if(finalDist < 114) 
{
if(finalDist < 113) 
{
return 0.789063;} else {
return 0.347656;
}} else {
if(finalDist < 115) 
{
return 0.113281;} else {
return 0.886719;
}
}} else {
if(finalDist < 118) 
{
if(finalDist < 117) 
{
return 0.398438;} else {
return 0.691406;
}} else {
if(finalDist < 119) 
{
return 0.34375;} else {
return 0.230469;
}
}
}} else {
if(finalDist < 124) 
{
if(finalDist < 122) 
{
if(finalDist < 121) 
{
return 0.425781;} else {
return 0.175781;
}} else {
if(finalDist < 123) 
{
return 0.625;} else {
return 0.410156;
}
}} else {
if(finalDist < 126) 
{
if(finalDist < 125) 
{
return 0.558594;} else {
return 0.0742188;
}} else {
if(finalDist < 127) 
{
return 0.710938;} else {
return 0.140625;
}
}
}
}
}
}
}} else {
if(finalDist < 192) 
{
if(finalDist < 160) 
{
if(finalDist < 144) 
{
if(finalDist < 136) 
{
if(finalDist < 132) 
{
if(finalDist < 130) 
{
if(finalDist < 129) 
{
return 0.621094;} else {
return 0.457031;
}} else {
if(finalDist < 131) 
{
return 0.667969;} else {
return 0.3125;
}
}} else {
if(finalDist < 134) 
{
if(finalDist < 133) 
{
return 0.78125;} else {
return 0.167969;
}} else {
if(finalDist < 135) 
{
return 0.847656;} else {
return 0.0117188;
}
}
}} else {
if(finalDist < 140) 
{
if(finalDist < 138) 
{
if(finalDist < 137) 
{
return 0.769531;} else {
return 0.570313;
}} else {
if(finalDist < 139) 
{
return 0.890625;} else {
return 0.00390625;
}
}} else {
if(finalDist < 142) 
{
if(finalDist < 141) 
{
return 0.808594;} else {
return 0.199219;
}} else {
if(finalDist < 143) 
{
return 0.507813;} else {
return 0.992188;
}
}
}
}} else {
if(finalDist < 152) 
{
if(finalDist < 148) 
{
if(finalDist < 146) 
{
if(finalDist < 145) 
{
return 0.546875;} else {
return 0.179688;
}} else {
if(finalDist < 147) 
{
return 0.902344;} else {
return 0.0507813;
}
}} else {
if(finalDist < 150) 
{
if(finalDist < 149) 
{
return 0.53125;} else {
return 0.269531;
}} else {
if(finalDist < 151) 
{
return 0.589844;} else {
return 0.949219;
}
}
}} else {
if(finalDist < 156) 
{
if(finalDist < 154) 
{
if(finalDist < 153) 
{
return 0.496094;} else {
return 0.273438;
}} else {
if(finalDist < 155) 
{
return 0.144531;} else {
return 0.339844;
}
}} else {
if(finalDist < 158) 
{
if(finalDist < 157) 
{
return 0.679688;} else {
return 0.375;
}} else {
if(finalDist < 159) 
{
return 0.863281;} else {
return 0.226563;
}
}
}
}
}} else {
if(finalDist < 176) 
{
if(finalDist < 168) 
{
if(finalDist < 164) 
{
if(finalDist < 162) 
{
if(finalDist < 161) 
{
return 0.683594;} else {
return 0.355469;
}} else {
if(finalDist < 163) 
{
return 0.734375;} else {
return 0.429688;
}
}} else {
if(finalDist < 166) 
{
if(finalDist < 165) 
{
return 0.996094;} else {
return 0.109375;
}} else {
if(finalDist < 167) 
{
return 0.738281;} else {
return 0.324219;
}
}
}} else {
if(finalDist < 172) 
{
if(finalDist < 170) 
{
if(finalDist < 169) 
{
return 0.09375;} else {
return 0.800781;
}} else {
if(finalDist < 171) 
{
return 0.957031;} else {
return 0.476563;
}
}} else {
if(finalDist < 174) 
{
if(finalDist < 173) 
{
return 0.246094;} else {
return 0.945313;
}} else {
if(finalDist < 175) 
{
return 0.4375;} else {
return 0.0546875;
}
}
}
}} else {
if(finalDist < 184) 
{
if(finalDist < 180) 
{
if(finalDist < 178) 
{
if(finalDist < 177) 
{
return 0.929688;} else {
return 0.015625;
}} else {
if(finalDist < 179) 
{
return 0.242188;} else {
return 0.820313;
}
}} else {
if(finalDist < 182) 
{
if(finalDist < 181) 
{
return 0.597656;} else {
return 0.195313;
}} else {
if(finalDist < 183) 
{
return 0.640625;} else {
return 0.414063;
}
}
}} else {
if(finalDist < 188) 
{
if(finalDist < 186) 
{
if(finalDist < 185) 
{
return 0.707031;} else {
return 0.371094;
}} else {
if(finalDist < 187) 
{
return 0.609375;} else {
return 0.757813;
}
}} else {
if(finalDist < 190) 
{
if(finalDist < 189) 
{
return 0.0585938;} else {
return 0.632813;
}} else {
if(finalDist < 191) 
{
return 0.316406;} else {
return 0.75;
}
}
}
}
}
}} else {
if(finalDist < 224) 
{
if(finalDist < 208) 
{
if(finalDist < 200) 
{
if(finalDist < 196) 
{
if(finalDist < 194) 
{
if(finalDist < 193) 
{
return 0.164063;} else {
return 0.464844;
}} else {
if(finalDist < 195) 
{
return 0.660156;} else {
return 0.894531;
}
}} else {
if(finalDist < 198) 
{
if(finalDist < 197) 
{
return 0.320313;} else {
return 0.460938;
}} else {
if(finalDist < 199) 
{
return 0.917969;} else {
return 0.855469;
}
}
}} else {
if(finalDist < 204) 
{
if(finalDist < 202) 
{
if(finalDist < 201) 
{
return 0.214844;} else {
return 0.0;
}} else {
if(finalDist < 203) 
{
return 0.171875;} else {
return 0.515625;
}
}} else {
if(finalDist < 206) 
{
if(finalDist < 205) 
{
return 0.898438;} else {
return 0.191406;
}} else {
if(finalDist < 207) 
{
return 0.796875;} else {
return 0.519531;
}
}
}
}} else {
if(finalDist < 216) 
{
if(finalDist < 212) 
{
if(finalDist < 210) 
{
if(finalDist < 209) 
{
return 0.867188;} else {
return 0.367188;
}} else {
if(finalDist < 211) 
{
return 0.566406;} else {
return 0.0703125;
}
}} else {
if(finalDist < 214) 
{
if(finalDist < 213) 
{
return 0.128906;} else {
return 0.777344;
}} else {
if(finalDist < 215) 
{
return 0.0273438;} else {
return 0.265625;
}
}
}} else {
if(finalDist < 220) 
{
if(finalDist < 218) 
{
if(finalDist < 217) 
{
return 0.5;} else {
return 0.773438;
}} else {
if(finalDist < 219) 
{
return 0.90625;} else {
return 0.304688;
}
}} else {
if(finalDist < 222) 
{
if(finalDist < 221) 
{
return 0.0976563;} else {
return 0.421875;
}} else {
if(finalDist < 223) 
{
return 0.5625;} else {
return 0.253906;
}
}
}
}
}} else {
if(finalDist < 240) 
{
if(finalDist < 232) 
{
if(finalDist < 228) 
{
if(finalDist < 226) 
{
if(finalDist < 225) 
{
return 0.0820313;} else {
return 0.980469;
}} else {
if(finalDist < 227) 
{
return 0.277344;} else {
return 0.703125;
}
}} else {
if(finalDist < 230) 
{
if(finalDist < 229) 
{
return 0.503906;} else {
return 0.328125;
}} else {
if(finalDist < 231) 
{
return 0.636719;} else {
return 0.574219;
}
}
}} else {
if(finalDist < 236) 
{
if(finalDist < 234) 
{
if(finalDist < 233) 
{
return 0.953125;} else {
return 0.363281;
}} else {
if(finalDist < 235) 
{
return 0.449219;} else {
return 0.664063;
}
}} else {
if(finalDist < 238) 
{
if(finalDist < 237) 
{
return 0.816406;} else {
return 0.964844;
}} else {
if(finalDist < 239) 
{
return 0.0234375;} else {
return 0.648438;
}
}
}
}} else {
if(finalDist < 248) 
{
if(finalDist < 244) 
{
if(finalDist < 242) 
{
if(finalDist < 241) 
{
return 0.804688;} else {
return 0.605469;
}} else {
if(finalDist < 243) 
{
return 0.84375;} else {
return 0.210938;
}
}} else {
if(finalDist < 246) 
{
if(finalDist < 245) 
{
return 0.832031;} else {
return 0.933594;
}} else {
if(finalDist < 247) 
{
return 0.417969;} else {
return 0.0859375;
}
}
}} else {
if(finalDist < 252) 
{
if(finalDist < 250) 
{
if(finalDist < 249) 
{
return 0.695313;} else {
return 0.148438;
}} else {
if(finalDist < 251) 
{
return 0.0429688;} else {
return 0.59375;
}
}} else {
if(finalDist < 254) 
{
if(finalDist < 253) 
{
return 0.238281;} else {
return 0.335938;
}} else {
if(finalDist < 255) 
{
return 0.761719;} else {
return 0.394531;
}
}
}
}
}
}
}
}    
    return 0.0;
}


#ifdef JON_MOD_USE_RETROREFLECTIVE_DIFFUSE_MODEL
vec3 integrate_GGX_and_retroreflective_diffuse(float roughness, float n_dot_v)
{
  vec3 normal = vec3(0.0f, 0.0f, 1.0f);

  vec3 view = vec3(sqrt(1.0f - n_dot_v * n_dot_v), 0, n_dot_v);
  float a = 0.0f; float b = 0.0f; float c = 0.0f;
 #ifdef JON_MOD_USE_RETROREFLECTIVE_DIFFUSE_MODEL
	CONST uint num_samples = 256u;//the diffuse needs a ton more samples - and the specular ones looks even better with more too!
#else
	CONST uint num_samples = 32u;//was 32
#endif	
  for(uint i=0u; i< num_samples; ++i)
  {
	vec2 uv = hammersley_2d(i, num_samples);
	
	vec3 half_dir = importance_sample_GGX(uv, roughness, normal);
	vec3 light = 2 * dot(view, half_dir) * half_dir - view;
	float n_dot_l = max(0.0f, light.z);
	// float n_dot_l = light.z;
	float n_dot_h = clamp(half_dir.z, 0.0f, 1.0f);
	// float n_dot_h = half_dir.z;
	float v_dot_h = clamp(dot(view, half_dir), 0.0f, 1.0f);
	// float v_dot_h = dot(view, half_dir);
	if( n_dot_l > 0.0f)
	// if( true )
	{
		
		float k = (roughness*roughness)/2;
		float G = G_Smith(k, n_dot_v, n_dot_l);
		// float G = G_smith(roughness, n_dot_v, n_dot_l);
	
		float G_vis = G * v_dot_h / (n_dot_h * n_dot_v);
		// G_vis = Vis_Smith(roughness, n_dot_v, n_dot_l);
		// float G_vis = G / (4.0f*n_dot_l*n_dot_v);
		float F_c = pow(1.0f - v_dot_h, 5);
		// float F0 = 0.5f; // reflectance at normal incidence
		// float F_c = F0 + (1-F0)*pow( 1.0f - v_dot_h, 5 );
		a += (1.0f - F_c) * G_vis;
		b += F_c * G_vis;
#ifdef JON_MOD_USE_RETROREFLECTIVE_DIFFUSE_MODEL
		// we can throw the retroreflective diffuse BRDF in here!
		float a2 = roughness*roughness;
		float g = saturate((1.0 / 18.0) * log2(2.0 / a2 - 1.0));
		float f0 = (v_dot_h + pow5(1.0 - v_dot_h));
		float fdv = (1.0 - 0.75 * pow5(1.0 - n_dot_v));
		float fdl = (1.0 - 0.75 * pow5(1.0 - n_dot_l));
	
		// Rough (f0) to smooth (fdv * fdv) response interpolation
		float fd = mix(f0, fdv * fdl, saturate(2.2 * g - 0.5));
		
		// Retro reflectivity contribution.
		float fb = ((34.5 * g - 59.0) * g + 24.5) * v_dot_h * exp2(-max(73.2 * g - 21.2, 8.9) * sqrt(n_dot_h));
		c += (fd + fb) * n_dot_l;
#endif		
	}
	
  }
  vec3 sum = vec3(a, b, c * PI) * (1.0 / num_samples);
//  sum.z *= (1.0 / dot(sum, vec3(1.0)));
  return sum;
}

void main()
{
  	OUT_Color = vec4(0);
	
/*	
	//We can do this smarter if we want to use it!
	vec2 blue_noise = good_blue_noise(IO_uv0 * 256.0);//Makes a nice dither rotation
	float blue_noise_rot = atan(blue_noise.y, blue_noise.x);//unpack with sincos()
*/
    OUT_Color.xyz = integrate_GGX_and_retroreflective_diffuse(IO_uv0.x, IO_uv0.y);
	OUT_Color.a = 1.0;//blue_noise_rot;
  	// OUT_Color = vec4(IO_uv0, 1, 1);
}
#else
vec2 integrate_GGX(float roughness, float n_dot_v)
{
  vec3 normal = vec3(0.0f, 0.0f, 1.0f);

  vec3 view = vec3(sqrt(1.0f - n_dot_v * n_dot_v), 0, n_dot_v);
  float a = 0.0f; float b = 0.0f;
  CONST uint num_samples = 32u;
  for(uint i=0u; i< num_samples; ++i)
  {
    vec2 uv = hammersley_2d(i, num_samples);

    vec3 half_dir = importance_sample_GGX(uv, roughness, normal);
    vec3 light = 2 * dot(view, half_dir) * half_dir - view;
    float n_dot_l = max(0.0f, light.z);
    // float n_dot_l = light.z;
    float n_dot_h = clamp(half_dir.z, 0.0f, 1.0f);
    // float n_dot_h = half_dir.z;
    float v_dot_h = clamp(dot(view, half_dir), 0.0f, 1.0f);
    // float v_dot_h = dot(view, half_dir);

    if( n_dot_l > 0.0f)
    // if( true )
    {
      float k = (roughness*roughness)/2;
      float G = G_Smith(k, n_dot_v, n_dot_l);
      // float G = G_smith(roughness, n_dot_v, n_dot_l);

      float G_vis = G * v_dot_h / (n_dot_h * n_dot_v);
      // G_vis = Vis_Smith(roughness, n_dot_v, n_dot_l);
      // float G_vis = G / (4.0f*n_dot_l*n_dot_v);
      float F_c = pow(1.0f - v_dot_h, 5);
      // float F0 = 0.5f; // reflectance at normal incidence
      // float F_c = F0 + (1-F0)*pow( 1.0f - v_dot_h, 5 );
      a += (1.0f - F_c) * G_vis;
      b += F_c * G_vis;
    }
  }
  return vec2(a, b) / num_samples;
}

void main()
{
  	OUT_Color = vec4(0);
    OUT_Color.xy = integrate_GGX(IO_uv0.x, IO_uv0.y);
  	// OUT_Color = vec4(IO_uv0, 1, 1);
}
	
#endif