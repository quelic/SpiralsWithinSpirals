// pulsa + i - per variar la reducció del tamany de radi en execució
// pulsa q i w per apropar i allunyar el zoom
// mou el ratoli sobre la finestra per girar
// Javier Melenchón Maig 2017

int MAXPOINTS; //nombre de punts / hores
float stepHeight; //separació dels punts en z, s'inicialitza a 2*radius/MAXPOINTS.
float years = 1; //número de voltes del cercle exterior
float radius = 170; //radi de la volta principal
float reduction = 0.3; //reducció de tamany de radi
int wScreen, hScreen, wGUI, hGUI;
float rhoX=0.0, rhoY=0.0;
float tx=0.0, ty=0.0;
int recursiveLevel = 3; //espirals d'espirals d'espirals... En aquest cas, any(0), mesos(1), dies(2) i hores(3).
int [][] structure;
float [] data;
int firstDrawn, lastDrawn;
float zoomV = 1.0;
boolean test=false;
float progress=0.0;
float toReset=1.0;
boolean reset=false;
float direction=1;
int itemSelected=50;

void setup(){
  size(800,800,P3D);
  frameRate=50; 
  ortho(); 
  prepareScreenStructure();
  prepareDataStructure();
}

void prepareDataStructure(){
  Table table;
  int i = 0;
  // recursiveLevel ha de ser sempre 3 perquè les dades venen preparades per mitges hores.
  switch (recursiveLevel){
    case 1:
      MAXPOINTS = 12;
      break;
    case 2:
      MAXPOINTS = (31+28+31+30+31+30+31+31+30+31+30+31);
      break;
    case 3:
      // MAXPOINTS coincideix amb el número de files de la taula de data.csv
      MAXPOINTS = ((int)years)*(31+29+31+30+31+30+31+31+30+31+30+31)*48;
      break;
  }
  data = new float[MAXPOINTS];
  structure = new int[4][MAXPOINTS];
  table = loadTable("data.csv","header");
  //for (int i=0;i<MAXPOINTS;i++){
  for (TableRow row : table.rows()){
    // Aquí carregaríem les dades a data, en aquest cas és un color en hexadecimal
    //data[i] = (#000000+(int)i*(int)((16777216.0/MAXPOINTS)));
    
    //Carreguem la dada del fitxer data.csv (mitges hores de l'any 2016
    // MAXPOINTS coincideix amb el número de files de la taula
    data[i] = row.getFloat("T");
    
    // level 1: años structure[0];
    structure[0][i] = (int)years;
    // level 2: 12 meses cada año. 12 vueltas. structure[1]
    structure[1][i] = 12;
    // level 3: depende: 31 28 31 30 31 30 31 31 30 31 30 31 vueltas. structure[2]
    if (i<24*31) {
      structure[2][i] = 31;
    }else if(i<(24*(31+29))){
      structure[2][i] = 29; 
    }else if(i<(24*(31+29+31))){
      structure[2][i] = 31; 
    }else if(i<(24*(31+29+31+30))){
      structure[2][i] = 30; 
    }else if(i<(24*(31+29+31+30+31))){
      structure[2][i] = 31; 
    }else if(i<(24*(31+29+31+30+31+30))){
      structure[2][i] = 30; 
    }else if(i<(24*(31+29+31+30+31+30+31))){
      structure[2][i] = 31; 
    }else if(i<(24*(31+29+31+30+31+30+31+31))){
      structure[2][i] = 31; 
    }else if(i<(24*(31+29+31+30+31+30+31+31+30))){
      structure[2][i] = 30; 
    }else if(i<(24*(31+29+31+30+31+30+31+31+30+31))){
      structure[2][i] = 31; 
    }else if(i<(24*(31+29+31+30+31+30+31+31+30+31+30))){
      structure[2][i] = 30; 
    }else {
      structure[2][i] = 31; 
    }
    // level 4: 48 cada día. 48 vueltas. structure [3]
    structure[3][i] = 48;
    i=i+1;
  }
}

void draw(){
  float thetaY = 2.0*mouseX/width*PI;
  float thetaX = 2.0*mouseY/height*PI;
  float thetaZ = 0;
  background(255);
  drawGUI();
  stroke(0);
  strokeWeight(0.5);
  drawScene(thetaX, thetaY, thetaZ, zoomV);
}

void drawScene(float thetaX, float thetaY, float thetaZ, float z){
  float p;
  pushMatrix();
  translate(wScreen/2,hScreen/2+hGUI,0);
  navigation();
  if (test==true){
    progress=progress+direction/(2*frameRate);
    if (progress>1.0) {
      progress=1.0;
    } else if(progress<0.0){
      progress=0.0;
      test=false;
    }
    p = (1-cos(PI*progress))/2;
    scale(p*6+1);
    centerInData(p);
  }
  escenaFromScratch();
  popMatrix();
}

void navigation(){
  float tr=0.0;;
  if (reset && toReset>0.0) {
    toReset = toReset-1.0/(2.0*frameRate);
    if (toReset<=0.0){
      tr=0.0;
      toReset = 1.0;
      rhoX = 0.0;
      rhoY = 0.0;
      tx = 0;
      ty = 0;
      zoomV = 1.0;
      reset = false;
    } else {
      tr = (1+cos(PI*toReset))/2;
    }
  }
  rotateX(rhoX*(1-tr));
  rotateY(rhoY*(1-tr));
  //rotateZ(thetaZ);
  scale((zoomV-1)*(1-tr)+1);
  translate(tx*(1-tr),ty*(1-tr),0);
}

void centerInData(float t){
  int i=itemSelected;
  float incTheta = 2*PI/MAXPOINTS;
  float theta, radiusN;
  stepHeight = 2*years*radius/MAXPOINTS;
  
  rotateX(-PI/2);
  theta = t*i*incTheta*structure[0][i]*structure[1][i]*structure[2][i];
  rotateY(-theta);
  rotateX(-PI/2);
  radiusN = radius*reduction*reduction;
  translate(-t*radiusN*(cos(theta)),-t*radiusN*(sin(theta)),0.00);
  
  theta = t*i*incTheta*structure[0][i]*structure[1][i];
  rotateY(-theta);
  rotateX(-PI/2);
  radiusN = radius*reduction;
  translate(-t*radiusN*(cos(theta)),-t*radiusN*(sin(theta)),0.00);
  
  theta = t*i*incTheta*structure[0][i];
  rotateY(-theta);
  rotateX(-PI/2);
  translate(-t*radius*(cos(theta)),-t*radius*(sin(theta)),0.00);
  translate(0,0,-t*i*stepHeight);
  translate(0,0,t*years*radius);

  //scale(1.0/z);
  //translate(-wScreen/2,-hScreen/2-hGUI,0);
  //translate(wScreen/2,hScreen/2+hGUI,0);
  //scale(z);
}

void escenaFromScratch(){
  float incTheta = 2*PI/MAXPOINTS;
  stepHeight = 2*years*radius/MAXPOINTS;
  translate(0,0,-years*radius);
  pushMatrix();
  if (test){
    firstDrawn=itemSelected;
    lastDrawn=itemSelected;
  } else {
    firstDrawn=(int)(MAXPOINTS*vFirst);
    lastDrawn=(int)(MAXPOINTS*vLast);
  }
  for (int i=firstDrawn;i<lastDrawn;i++){
    pushMatrix();
    translate(0,0,i*stepHeight);
    // es dibuixen tots els punts seguits.
    drawSpiralPoint(i,recursiveLevel,i*incTheta,radius,data[i]);
    popMatrix();
  }
  for (int i=0;i<firstDrawn;i++){
    pushMatrix();
    translate(0,0,i*stepHeight);
    // es dibuixen tots els punts seguits.
    drawSpiralPoint(i,recursiveLevel,i*incTheta,radius,data[i]);
    popMatrix();
  }
  for (int i=lastDrawn;i<MAXPOINTS;i++){
    pushMatrix();
    translate(0,0,i*stepHeight);
    // es dibuixen tots els punts seguits.
    drawSpiralPoint(i,recursiveLevel,i*incTheta,radius,data[i]);
    popMatrix();
  }  
  /*
  for (int i=0;i<MAXPOINTS;i++){
    pushMatrix();
    translate(0,0,i*stepHeight);
    // es dibuixen tots els punts seguits.
    drawSpiralPoint(i,recursiveLevel,i*incTheta,radius,data[i]);
    popMatrix();
  }*/
  popMatrix();
}

void drawSpiralPoint(int n,int level, float theta, float radius, float datum){
  if (level==0){
    drawItem(n,radius/reduction,datum);
  } else {
    int currentLevel = recursiveLevel - level;
    float newTheta, x, y;
    newTheta = theta*structure[currentLevel][n];
    x = radius*(cos(newTheta));
    y = radius*(sin(newTheta));
    translate(x,y,0.00);
    pushMatrix();
    rotateX(PI/2);
    rotateY(newTheta);
    drawSpiralPoint(n,level-1,newTheta,radius*reduction,datum);
    popMatrix();
  }  
}

void drawItem(int n,float radius, float datum){
  pushMatrix();
  rotateX(PI/2);
  if (n<firstDrawn || n>lastDrawn){
    //max ta: 33, min ta: 4 - slope: 29
    fill(datum*255/29-(4)*255/29,0,-datum*255/26+255*33/29,15); 
    noStroke();
    //stroke(0,15);
    rect(-radius/8.0,-radius/16.0,radius/1.0,radius/8.0);
  } else {
    fill(datum*255/29-(4)*255/29,0,-datum*255/26+255*33/29); 
    noStroke();
    //stroke(0);
    rect(-radius/8.0,-radius/16.0,radius/1.0,radius/8.0);
    pushMatrix();
    scale(0.125);
    textAlign(LEFT,BASELINE);
    textSize(48);
    // escala 8x, per aconseguir millor definició de typeface
    //text(str(datum),radius*8.00,-2*radius,8*radius,4.0*radius);
    popMatrix();    
  }
  popMatrix();
}