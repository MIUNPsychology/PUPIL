/* --- START OF LICENSE AND COPYRIGHT BLURB ---

   This file is a part of the PUPIL project, see
   
     http://github.com/MIUNPsychology/PUPIL

   Copyright 2016 Department of Psychology, Mid Sweden University

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   --- END OF LICENSE AND COPYRIGHT BLURB --- */



package sfw.net
{
  import sfw.*;
  import sfw.net.*;
  import flash.net.*;
  import flash.events.*;
  import flash.display.*;

  public class SFNetTable
  {
    private var data:Array = null;
    private var colNames:Array = null;

    public function SFNetTable(rows:uint, columns:uint, columnNames:Array = null)
    {
      var r:uint = 0;
      var c:uint = 0;

      data = new Array(rows);

      for(r = 0; r < rows; r++)
      {
        data[r] = new Array(columns);
        for(c = 0; c < columns; c++)
        {
          data[r][c] = "";
        }        
      }

      colNames = new Array();
      for(c = 0; c < columns; c++)
      {
        colNames[c] = "";
      }

      if(columnNames != null)
      {
        var max:uint = columns;
        if(max > columnNames.length)
        {
          max = columnNames.length;
        }

        for(c = 0; c < max; c++)
        {
          colNames[c] = columnNames[c];
        }
      }
    }

    public function getRowCount():uint
    {
      return data.length;
    }

    public function getColumnCount():uint
    {
      return data[0].length;
    }

    public function getColumnName(colNr:uint):String
    {
      return colNames[colNr];
    }

    public function getColumnNumber(colName:String):uint
    {
      var n:uint = 0;
      var i:uint = 0;

      for(i = 0; i < colNames.length; i++)
      {
        if(colNames[i] == colName)
        {
          n = i;
        }
      }

      return n;
    }


    public static function makeTableFromCSV(csvdata:String, firstRowIsNames:Boolean = false,columnSeparator:String = "|", rowSeparator:String = ";"):SFNetTable
    {
      var rows:Array = csvdata.split(rowSeparator);
      var cols:Array = rows[0].split(columnSeparator);

      var cnames:Array = null;
      if(firstRowIsNames)
      {
        cnames = cols;
      }

      var obj:SFNetTable = new SFNetTable(rows.length,cols.length,cnames);

      var r:uint = 0;
      var c:uint = 0;

      for(r = 0; r < rows.length; r++)
      {
        cols = rows[r].split(columnSeparator);
        for(c = 0; c < cols.length; c++)
        {
          obj.setValue(r,c,cols[c]);
        }
      }

      return obj;
    }

    public static function makeTableFromXML(xmldata:XML):SFNetTable
    {
      if(xmldata == null)
      {
        return null;
      }

      if(xmldata.localName() != "nettable")
      {
        return null;
      }

      var tmp:XML = new XML(xmldata.tablemetadata);

      var rows:uint = uint(tmp.rows);
      var cols:uint = uint(tmp.columns);

      var tmpColNames:Array = new Array();
      var i:uint = 0;
      for(i = 0; i < cols; i++)
      {
        tmpColNames[i] = "";
      }

      var names:XMLList = tmp.elements("columnname");

      var cn:XML;

      var name:String = "";
      var coln:String = "";

      var cln:uint = 0;

      for each(cn in names)
      {
        name = cn.toString();
        coln = cn.@colnr;
        cln = uint(coln);

        tmpColNames[cln] = name;
      }

      var tbl:SFNetTable = new SFNetTable(rows,cols,tmpColNames);

      tmp = xmldata.elements("tabledata")[0];

      var rws:XMLList = tmp.elements("row");

      var rown:String = "";
      var rwn:uint = 0;

      var acol:XML;
      var cls:XMLList;
      var value:String = "";

      for each(tmp in rws)
      {
        rown = tmp.@rownr;
        rwn = uint(rown);

        cls = tmp.elements("column");

        for each(acol in cls)
        {
          coln = acol.@colnr;
          cln = uint(coln);
          value = acol.toString();
          tbl.setValue(rwn,cln,value);
        }

      }

      SFScreen.addDebug(tbl.toString());

      return null;

    }


    public function setValue(row:uint, column:uint, value:String):void
    {
      data[row][column] = value;
    }

    public function getValue(row:uint, column:uint):String
    {
      return data[row][column];
    }

    public function getRowAsCSV(row:uint, separator:String = "|"):String
    {
      return "";
    }

    public function getColumnAsCSV(column:uint, separator:String = ","):String
    {
      return "";
    }

    public function getTableAsCSV(namesAsFirstRow:Boolean = false, columnSeparator:String = "|", rowSeparator:String = ";"):String
    {
      var table:String = "";

      var isFirstRow:Boolean = true;
      var isFirstCol:Boolean = true;

      if(namesAsFirstRow)
      {
        var cn:uint = 0;
        var name:String = "";

        for(cn = 0; cn < colNames.length; cn++)
        {
          name = colNames[cn];
          if(!isFirstCol)
          {
            table = table + columnSeparator;
          }
          else
          {
            isFirstCol = false;
          }

          table = table + name;
        }
        isFirstRow = false;
      }

      var r:uint = 0;
      var c:uint = 0;

      var row:Array = null;

      for(r = 0; r < data.length; r++)
      {
        if(!isFirstRow)
        {
          table = table + rowSeparator;
        }
        else
        {
          isFirstRow = false;
        }

        row = data[r];

        isFirstCol = true;

        for(c = 0; c < row.length; c++)
        {
          if(!isFirstCol)
          {
            table = table + columnSeparator;
          }
          else
          {
            isFirstCol = false;
          }

          table = table + row[c];
        }
      }

      return table;
    }

    public function getTableAsXML():XML
    {
      var xml:XML = <nettable></nettable>;
      var tablemetadata:XML = <tablemetadata></tablemetadata>;
      var tabledata:XML = <tabledata></tabledata>;

      tablemetadata.appendChild("<rows>" + data.length + "</rows>");
      tablemetadata.appendChild("<columns>" + data[0].length + "</columns>");

      var c:uint = 0;
      var r:uint = 0;

      var rowData:Array = null;

      var tmp:XML;

      for(c = 0; c < colNames.length; c++)
      {
        tmp = <columnname></columnname>;
        tmp.appendChild(colNames[c]);
        tmp.@colnr = c;
        tablemetadata.appendChild(tmp);
      }

      var row:String = "";
      
      for(r = 0; r < data.length; r++)
      {
        row = '<row rownr="' + r + '">';
        rowData = data[r];

        for(c = 0; c < rowData.length; c++)
        {
          row = row + '<column colnr="' + c + '">' + rowData[c] + '</column>';
        }

        row = row + "</row>";

        tabledata.appendChild(row);
      }

      xml.appendChild(tablemetadata);
      xml.appendChild(tabledata);

      return xml;
    }

    public function toString():String
    {
      return getTableAsCSV(true,"\t", "\n");
    }

  }

}

