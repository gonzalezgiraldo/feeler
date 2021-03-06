// first line of the  should be the column headers
// first column should be the row titles
// all other values are expected to be floats
// getFloat(0, 0) returns the first data value in the upper lefthand corner
// files should be saved as "text, tab-delimited"
// empty rows are ignored
// extra whitespace is ignored


class FloatTable {
  int rowCount;
  int rowCount1;
  int rowCount2;
  int rowCount3;
  int columnCount;
  float[][] data;
  String[] rowNames;
  String[] columnNames;

  FloatTable(String filename) {
    String[]  rows = loadStrings(filename);
    
    if(rows.length > 0){ // check if file is not empty
      String[] columns = split(rows[0], TAB);
  
      columnNames = subset(columns, 1);               // upper-left corner ignored
      scrubQuotes(columnNames);
      columnCount = columnNames.length;
  
      rowNames = new String[rows.length];
      data = new float[rows.length][];
      // start reading at row 1, because the first row was only the column headers
  
      for (int i = 0; i < rows.length; i++) {
        if (trim(rows[i]).length() == 0) {
          continue; // skip empty rows
        }
        if (rows[i].startsWith("#")) {
          continue;  // skip comment lines
        }
  
        // split the row on the tabs
        String[] pieces = split(rows[i], TAB);
        scrubQuotes(pieces);
    
        // copy row title
        rowNames[rowCount] = pieces[0];
        // copy data into the table starting at pieces[1]
        //data[rowCount] = parseFloat(subset(pieces, 1));
        data[rowCount] = parseFloat(pieces);
        
        //check if all columns have content
        if(data[rowCount].length == 13){
          //then increment the number of valid rows found so far
          rowCount++;
        }
  
      }
      // resize the 'data' array as necessary
      data = (float[][]) subset(data, 0, rowCount);
    }
  }


  void scrubQuotes(String[] array) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].length() > 2) {
        // remove quotes at start and end, if present
        if (array[i].startsWith("\"") && array[i].endsWith("\"")) {
          array[i] = array[i].substring(1, array[i].length() - 1);
        }
      }
      // make double quotes into single quotes
      array[i] = array[i].replaceAll("\"\"", "\"");
    }
  }


  int getRowCount(int i) {
    rowCount1 = 0;
    rowCount2 = 0;
    rowCount3 = 0;
    
    /*
    if(data[rowCount-1].length == 13){
      //println("data[" + i + "][11]: " + data[rowCount-1][11]);
      println(rowCount);
      println("length == 13");
    } else {
      println(rowCount);
      println("length != 13");
    }
    */
    
    for (int o = 0; o < rowCount; o++) {
      if (data[o][11] == 1) rowCount1++; 
      else if (data[o][11] == 2) rowCount2++;          
      else if (data[o][11] == 3) rowCount3++;
    }
    
    if (i == 1) {
      return rowCount1;
    } else if (i == 2) {
      return rowCount2;
    } else if (i == 3) {
      return rowCount3;
    } else {
      return rowCount;
    }
      
  }


  String getRowName(int rowIndex) {
    return rowNames[rowIndex];
  }


  String[] getRowNames() {
    return rowNames;
  }


  // Find a row by its name, returns -1 if no row found. 
  // This will return the index of the first row with this name.
  // A more efficient version of this function would put row names
  // into a Hashtable (or HashMap) that would map to an integer for the row.
  int getRowIndex(String name) {
    for (int i = 0; i < rowCount; i++) {
      if (rowNames[i].equals(name)) {
        return i;
      }
    }
    //println("No row named '" + name + "' was found");
    return -1;
  }


  // technically, this only returns the number of columns 
  // in the very first row (which will be most accurate)
  int getColumnCount() {
    return columnCount;
  }


  String getColumnName(int colIndex) {
    return columnNames[colIndex];
  }


  String[] getColumnNames() {
    return columnNames;
  }


  float getFloat(int rowIndex, int col) {
    // Remove the 'training wheels' section for greater efficiency
    // It's included here to provide more useful error messages

    // begin training wheels
    if ((rowIndex < 0) || (rowIndex >= data.length)) {
      throw new RuntimeException("There is no row " + rowIndex);
    }
    if ((col < 0) || (col >= data[rowIndex].length)) {
      throw new RuntimeException("Row " + rowIndex + " does not have a column " + col);
    }
    // end training wheels

    return data[rowIndex][col];
  }


  boolean isValid(int row, int col) {
    if (row < 0) return false;
    if (row >= rowCount) return false;
    //if (col >= columnCount) return false;
    if (col >= data[row].length) return false;
    if (col < 0) return false;
    return !Float.isNaN(data[row][col]);
  }


  float getColumnMin(int col) {

    float m = Float.MAX_VALUE;
    for (int row = 0; row < rowCount; row++) {
      if (data[row][11] == 1 || data[row][11] == 2 || data[row][11] == 3)
        if (isValid(row, col)) {
          if (data[row][col] < m) {
            m = data[row][col];
          }
        }
    }
    return m;
  }

  long getStateStart(int state) {
    boolean boolstart = false;
    boolean boolend = false;
    long startState = 0;
    for (int row = 0; row < rowCount; row++) {
      if (data[row][11] == state) {
        if (boolstart == false) {
          startState = row;
          boolstart = true;
        }
        if (boolstart == true && data[row][11] != state) {
          boolend = true;
        }
        if (boolend == true && boolstart == true && data[row][11] == state) {
          startState = row;
          boolstart = true;
          boolend = false;
        }
      }
    } 
    return startState;
  }
  
 long getStateEnd(int state) {
    boolean boolstart = false;
    boolean boolend = false;
    long endState = 0;
    for (int row = 0; row < rowCount; row++) {
      if (data[row][11] == state) {
        if (boolstart == false) {
          boolstart = true;
        }
        if (boolstart == true && data[row][11] != state) {
          boolend = true;
          endState = row;
        }
        if (boolend == true && boolstart == true && data[row][11] == state) {
          boolstart = true;
          boolend = false;
        }
      }
    } 
    return endState;
  }
  
  float getColumnMax(int col) {
    float m = -Float.MAX_VALUE;
    for (int row = 0; row < rowCount; row++) {
      if (data[row][11] == 1 || data[row][11] == 2 || data[row][11] == 3)
        if (isValid(row, col)) {
          if (data[row][col] > m) {
            m = data[row][col];
          }
        }
    }
    return m;
  }


  float getRowMin(int row) {
    float m = Float.MAX_VALUE;
    for (int col = 0; col < columnCount; col++) {
      if (isValid(row, col)) {
        if (data[row][col] < m) {
          if (data[row][col] > 0)
            m = data[row][col];
        }
      }
    }
    return m;
  } 


  float getRowMax(int row) {
    float m = -Float.MAX_VALUE;
    for (int col = 0; col < columnCount; col++) {
      if (isValid(row, col)) {
        if (data[row][col] > m) {
          m = data[row][col];
        }
      }
    }
    return m;
  }


  float getTableMin(int col) {
    float m = Float.MAX_VALUE;
    for (int row = 0; row < rowCount; row++) {
      if (isValid(row, col)) {
        if (data[row][col] < m) {
          m = data[row][col];
        }
      }
    }
    return m;
  }


  float getTableMax(int col) {
    float m = -Float.MAX_VALUE;
    for (int row = 0; row < rowCount; row++) {
      if (isValid(row, col)) {
        if (data[row][col] > m) {
          m = data[row][col];
        }
      }
    }
    return m;
  }
}