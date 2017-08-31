package 
{
	
	/**
	$(CBI)* ...
	$(CBI)* @author SARI
	$(CBI)*/
	public class KeyCodeNames 
	{
		
		public static function getName(keyCode:Number, charCode:Number):String {
			
			switch(keyCode) {
				
case 8:return "Backspace"
case 9:return "Tab"
case 13:return "Enter"
case 16:return "Shift"
case 17:return "Control"
case 20:return "CapsLock"
case 27:return "Esc"
case 32:return "Spacebar"
case 33:return "PageUp"
case 34:return "PageDown"
case 35:return "End"
case 36:return "Home"
case 37:return "LeftArrow"
case 38:return "UpArrow"
case 39:return "RightArrow"
case 40:return "DownArrow"
case 45:return "Insert"
case 46:return "Delete"
case 144:return "NumLock"
case 145:return "ScrLk"
case 19:return "Pause/Break"
case 65:return "A"
case 66:return "B"
case 67:return "C"
case 68:return "D"
case 69:return "E"
case 70:return "F"
case 71:return "G"
case 72:return "H"
case 73:return "I"
case 74:return "J"
case 75:return "K"
case 76:return "L"
case 77:return "M"
case 78:return "N"
case 79:return "O"
case 80:return "P"
case 81:return "Q"
case 82:return "R"
case 83:return "S"
case 84:return "T"
case 85:return "U"
case 86:return "V"
case 87:return "W"
case 88:return "X"
case 89:return "Y"
case 90:return "Z"
/*
case 65:return "a"
case 66:return "b"
case 67:return "c"
case 68:return "d"
case 69:return "e"
case 70:return "f"
case 71:return "g"
case 72:return "h"
case 73:return "i"
case 74:return "j"
case 75:return "k"
case 76:return "l"
case 77:return "m"
case 78:return "n"
case 79:return "o"
case 80:return "p"
case 81:return "q"
case 82:return "r"
case 83:return "s"
case 84:return "t"
case 85:return "u"
case 86:return "v"
case 87:return "w"
case 88:return "x"
case 89:return "y"
case 90:return "z"
*/
case 48:return "0"
case 49:return "1"
case 50:return "2"
case 51:return "3"
case 52:return "4"
case 53:return "5"
case 54:return "6"
case 55:return "7"
case 56:return "8"
case 57:return "9"
/*
case 186:return ";:"
case 187:return "=+"
case 189:return "-_"
case 191:return "/?"
case 192:return "`~"
case 219:return "[{"
case 220:return "\|"
case 221:return "]}"
case 222:return "\"'"
*/

// check if it has special characters
case 186:{var c0:String = ";:" ;if (String.fromCharCode(charCode) != "") { return String.fromCharCode(charCode) } else { return c0 }}break
case 187:{var c1:String = "=+" ;if (String.fromCharCode(charCode) != "") { return String.fromCharCode(charCode) } else { return c1 }}break
case 189:{var c2:String = "-_" ;if (String.fromCharCode(charCode) != "") { return String.fromCharCode(charCode) } else { return c2 }}break
case 191:{var c3:String = "/?" ;if (String.fromCharCode(charCode) != "") { return String.fromCharCode(charCode) } else { return c3 }}break
case 192:{var c4:String = "`~" ;if (String.fromCharCode(charCode) != "") { return String.fromCharCode(charCode) } else { return c4 }}break
case 219:{var c5:String = "[{" ;if (String.fromCharCode(charCode) != "") { return String.fromCharCode(charCode) } else { return c5 }}break
case 220:{var c6:String = "\\|" ;if (String.fromCharCode(charCode) != "") { return String.fromCharCode(charCode) } else { return c6 }}break
case 221:{var c7:String = "]}" ;if (String.fromCharCode(charCode) != "") { return String.fromCharCode(charCode) } else { return c7 }}break
case 222:{var c8:String = "\"'";if (String.fromCharCode(charCode) != "") { return String.fromCharCode(charCode) } else { return c8 }}break

case 188:return ","
case 190:return "."
case 191:return "/"
case 96:return "Numpad 0"
case 97:return "Numpad 1"
case 98:return "Numpad 2"
case 99:return "Numpad 3"
case 100:return "Numpad 4"
case 101:return "Numpad 5"
case 102:return "Numpad 6"
case 103:return "Numpad 7"
case 104:return "Numpad 8"
case 105:return "Numpad 9"
case 106:return "Numpad Multiply"
case 107:return "Numpad Add"
//case 13:return "Numpad Enter"//duplicate case
case 109:return "Numpad Subtract"
case 110:return "Numpad Decimal"
case 111:return "Numpad Divide"
case 112:return "F1"
case 113:return "F2"
case 114:return "F3"
case 115:return "F4"
case 116:return "F5"
case 117:return "F6"
case 118:return "F7"
case 119:return "F8"
case 120:return "F9"
//F10 = nokey
case 122:return "F11"
case 123:return "F12"
case 124:return "F13"
case 125:return "F14"
case 126:return "F15"

default:
{
	if (String.fromCharCode(charCode) != "") {
		return String.fromCharCode(charCode)
	} else {
		return keyCode.toString()
	}
	
}
				
				
			}
			
		}
		

		
	}
	
}