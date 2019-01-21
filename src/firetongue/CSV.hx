/**
 * Copyright (c) 2013 Level Up Labs, LLC
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */

package firetongue;

/**
 * A simple CSV (comma separated values) structure
 * @author Lars Doucet
 */

class CSV 
{
	public var fields:Array<String>;
	public var grid:Array<Array<String>>;
	
	/**
	 * Parses CSV formatted string into a useable data structure
	 * @param	input csv-formatted string
	 * @param	delimeter string that separates cells
	 */
	
	public function new(input:String, delimeter:String=',', quoted:Bool=true) 
	{
		_delimeter = delimeter;
		_quoted = quoted;
		if (input != "")
		{
			processRows(getRows(input));
		}
	}
	
	public function destroy():Void
	{
		clearArray(grid);
		clearArray(fields);
		grid = null;
		fields = null;
	}
	
	/********PRIVATE**********/
	
	private var _rgx:EReg;
	private var _delimeter:String = "";
	private var _quoted:Bool;
	
	private function clearArray(array:Array<Dynamic>):Void
	{
		if (array == null) return;
		var i:Int = array.length - 1; 
		while (i >= 0) 
		{
			destroyThing(array[i]);
			array[i] = null;
			array.splice(i, 1);
			i--;
		}
		array = null;
	}
	
	private function destroyThing(thing:Dynamic):Void
	{
		if (thing == null) return;
		
		if (Std.is(thing, Array))
		{
			clearArray(thing);
		}
		
		thing = null;
	}
	
	private function getCells(row:String):Array<String>
	{
		if (_rgx == null)
		{
			//If the last cell in the row ends with the delimeter, trim it off before splitting
			if (row.charAt(row.length - 1) == _delimeter)
			{
				row = row.substr(0, row.length - 1);
			}
			
			if (_delimeter == ',')
			{
				_rgx = ~/,(?=(?:[^\x22]*\x22[^\x22]*\x22)*(?![^\x22]*\x22))/gm;
				// Matches a well formed CSV cell, ie "thing1" or "thing ,, 5" etc
				// "\x22" is the invocation for the double-quote mark.
				// UTF-8 ONLY!!!!
			}
			else
			{
				//You can provide your own customer delimeter, but we generally don't recommend it
				_rgx = new EReg(_delimeter + '(?=(?:[^\x22]*\x22[^\x22]*\x22)*(?![^\x22]*\x22))',"gm");
			}
		}
		return _rgx.split(row);
	}
	
	private function getRows(input:String):Array<String>
	{
		var endl:String = "\r\n";
		
		if (input.indexOf("\r\n") == -1)		//no windows-style endlines...
		{
			endl = "\n";						//try unix-style instead...
		}
		
		return input.split(endl);
	}
	
	private function processCells(cells:Array<String>,row:Int=0):Void
	{
		var col:Int = 0;
		var newline:Bool = false;
		var row_array:Array<String>=null;
		
		if (grid == null)
		{
			grid = new Array<Array<String>>();
			fields = [];
		}
		
		row_array = [];
		
		for (i in 0...cells.length)
		{
			var cell:String = "";
			if (_quoted)
			{
				cell = cells[i].substr(1, cells[i].length - 2);
			}
			else
			{
				cell = cells[i];
			}
			
			if (row == 0) 
			{
				fields.push(cell);		//get the fields
			}
			else
			{
				row_array.push(cell);	//get the row cells
			}
		}
		
		grid.push(row_array);
		clearArray(cells);
		cells = null;
	}
	
	private function processRows(rows:Array<String>):Void
	{
		for (i in 0...rows.length)
		{
			processCells(getCells(rows[i]), i);
		}
	}
}