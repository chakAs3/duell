/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package duell.helpers;

//import haxe.crypto.BaseCode;
//import haxe.io.Bytes;


class StringHelper 
{
	private static var seedNumber = 0;
	private static var usedFlatNames = new Map <String, String> ();
	private static var uuidChars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	
	/*
	private static var base64Encoder:BaseCode;
	private static var base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	public static function base64Decode(base64 : String) : ByteArray 
	{
		base64 = StringTools.trim (base64);
		base64 = StringTools.replace (base64, "=", "");
		
		if (base64Encoder == null) {
			
			base64Encoder = new BaseCode (Bytes.ofString (base64Chars));
			
		}
		
		var bytes = base64Encoder.decodeBytes (Bytes.ofString (base64));
		return ByteArray.fromBytes (bytes);
		
	}
	
	
	public static function base64Encode (bytes:ByteArray):String {
		
		var extension = switch (bytes.length % 3) {
			
			case 1: "==";
			case 2: "=";
			default: "";
			
		}
		
		if (base64Encoder == null) {
			
			base64Encoder = new BaseCode (Bytes.ofString (base64Chars));
			
		}
		
		return base64Encoder.encodeBytes (bytes).toString () + extension;
		
	}
	*/
	
	
	public static function formatArray (array : Array <Dynamic>) : String 
	{
		var output = "[ ";
		for(i in 0...array.length) 
		{
			output += array[i];
			
			if (i < array.length - 1) 
			{
				output += ", ";
			} 
			else 
			{
				output += " ";
			}
		}
		
		output += "]";
		
		return output;
	}
	
	
	public static function formatEnum(value : Dynamic) : String 
	{
		return Type.getEnumName(Type.getEnum (value)) + "." + value;
	}
	
	
	public static function formatUppercaseVariable(name : String) : String 
	{
		var variableName = "";
		var lastWasUpperCase = false;
		
		for (i in 0...name.length) 
		{
			var char = name.charAt (i);
			if(char == char.toUpperCase () && i > 0) 
			{
				if(lastWasUpperCase)
				{
					if(i == name.length - 1 || name.charAt (i + 1) == name.charAt (i + 1).toUpperCase ()) 
					{
						variableName += char;
					} 
					else 
					{
						variableName += "_" + char;
					}
					
				} 
				else 
				{
					variableName += "_" + char;
				}
				
				lastWasUpperCase = true;
			} 
			else 
			{
				variableName += char.toUpperCase ();
				lastWasUpperCase = false;
			}
		}
		
		return variableName;
	}
	
	
	public static function generateUUID(length : Int, radix : Null<Int> = null, seed : Null<Int> = null) : String 
	{
		var chars = uuidChars.split ("");
		
		if(radix == null || radix > chars.length) 
		{
			radix = chars.length;
		} 
		else if (radix < 2) 
		{
			radix = 2;
		}
		
		if (seed == null) 
		{
			seed = Math.floor (Math.random () * 2147483647.0);
		}
		
		var uuid = [];
		var seedValue:Int = Math.round(Math.abs(seed));
		
		for(i in 0...length)
		{
			seedValue = Std.int((seedValue * 16807.0) % 2147483647.0);
			uuid[i] = chars[0 | Std.int((seedValue / 2147483647.0) * radix)];
		}
		
		return uuid.join("");
	}
	
	
	
	public static function getFlatName(name : String) : String 
	{
		var chars = name.toLowerCase();
		var flatName = "";
		
		for (i in 0...chars.length) 
		{
			var code = chars.charCodeAt(i);
			
			if(
				(	i > 0 && 
					code >= "0".charCodeAt(0) && 
					code <= "9".charCodeAt(0)
				) 
				|| 
				(
					code >= "a".charCodeAt(0) && 
					code <= "z".charCodeAt(0)
				)
				|| 
				(
					code == "_".charCodeAt(0)
				)
			) 
			{
				flatName += chars.charAt(i);
			} 
			else 
			{
				flatName += "_";
			}
		}
		
		if (flatName == "") 
		{
			flatName = "_";
		}
		
		if(flatName.substr(0, 1) == "_") 
		{
			flatName = "file" + flatName;
		}
		
		while(usedFlatNames.exists(flatName)) 
		{
			// Find last digit ...
			var match = ~/(.*?)(\d+)/;
			
			if(match.match (flatName)) 
			{
				flatName = match.matched(1) + (Std.parseInt(match.matched (2)) + 1);
			} 
			else 
			{
				flatName += "1";
			}
		}
		
		usedFlatNames.set(flatName, "1");
		
		return flatName;
	}
	
	public static function getUniqueID() : String 
	{
		return StringTools.hex(seedNumber++, 8);
	}
	
	public static function underline(string : String, character = "=") : String 
	{
		return string + "\n" + StringTools.lpad("", character, string.length);
	}

	public static function strip(string : String, charsToRemove = " ") : String
	{
		var indexFromLeft = 0;
		var indexFromRight = 0;

		for(i in 0...string.length)
		{
			var foundCharToRemove = false;
			for(j in 0...charsToRemove.length)
			{
				if(string.charAt(i) == charsToRemove.charAt(j))
				{
					foundCharToRemove = true;
					break;
				}
			}

			if(foundCharToRemove)
				continue;
			else
			{
				indexFromLeft = i;
				break;
			}
		}

		var i = string.length - 1;

		while(i >= 0)
		{
			var foundCharToRemove = false;
			for(j in 0...charsToRemove.length)
			{
				if(string.charAt(i) == charsToRemove.charAt(j))
				{
					foundCharToRemove = true;
					break;
				}
			}

			if(foundCharToRemove)
				continue;
			else
			{
				indexFromRight = i + 1;
				break;
			}

			i -= 1;
		}

		if(indexFromLeft >= indexFromRight)
			return "";

		return string.substring(indexFromLeft, indexFromRight - indexFromLeft);
	}
}
