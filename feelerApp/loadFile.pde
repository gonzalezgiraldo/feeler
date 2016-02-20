public void loadFile(int n){
  filenameString = fileArray[n];

  data = new FloatTable(directory2 + "/" + filenameString);
  filenameCharArray = filenameString.toCharArray();

  rowCount = data.getRowCount(9);
  rowCount1 = data.getRowCount(1);
  rowCount2 = data.getRowCount(2);
  rowCount3 = data.getRowCount(3);
  columnCount = data.getColumnCount();

  state1start = data.getStateStart(1); // state1end = data.getStateEnd(1);
  state2start = data.getStateStart(2); // state2end = data.getStateEnd(2);
  state3start = data.getStateStart(3); // state3end = data.getStateEnd(3);

  if(data.data != null){
    for (int j = 0; j < data.data.length; j++) {
      if (data.data[j][11] == 1 || data.data[j][11] == 2) {
        attentionAverage += data.data[j][9];
        relaxationAverage += data.data[j][10];
      }
    }
    
    attentionAverage /= data.data.length;
    relaxationAverage /= data.data.length;
  }

  attentionAverageList[n - fileArray.length + listSize] = attentionAverage;
  relaxationAverageList[n - fileArray.length + listSize] = relaxationAverage;
}