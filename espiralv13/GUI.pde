DoubleSlider flc;
int mxTmp,myTmp;
float vFirst=0.0;
float vLast=1.0;

class Button {
  int x,y,w,h;
  Button(){
    x=0;y=0;w=0;h=0;
  }
  Button(int x, int y, int w, int h){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  boolean isPressed(int mx, int my){
    if (mx>x && my>y && mx<(x+w) && my<(y+h))
      return true;
    return false;
  }
  void draw(int c){
    noStroke();
    fill(c);
    rect(x,y,w,h);
  }
  void moveH(int d){
    x = x+d;
  }
  int cLeft(){
    return x;
  }
  int cRight(){
    return x+w;
  }
}

class DoubleSlider {
  static final int NONE = 0;
  static final int FIRST = 1;
  static final int LAST = 2;
  Button first;
  Button last;
  int x,y,w,h;
  boolean firstPressed;
  boolean lastPressed;
  DoubleSlider(){
    x=0;y=0;w=0;h=0;    
    first = new Button();
    last = new Button();
    firstPressed = false;
    lastPressed = false;
  }
  // w>h for all w and h pairs

  DoubleSlider(int x, int y, int w, int h){
    first = new Button(x,y,h,h);
    last = new Button(x+w-h,y,h,h);
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    firstPressed = false;
    lastPressed = false;
  }

  int isPressed(int mx, int my){
    if (first.isPressed(mx,my)){
      firstPressed = true;
      return FIRST;
    }
    if (last.isPressed(mx,my)){
      lastPressed = true;
      return LAST;
    }
    return NONE;
  }
  
  void release(){
    firstPressed = false;
    lastPressed = false;
  }
  
  void moveButton(int d){
    if (firstPressed && (first.x+d)>=x && (first.x+first.w+d)<=last.x){
      first.moveH(d);
    } else if(lastPressed && (last.x+d)>=(first.x+first.w) && (last.x+last.w+d)<=(x+w)){
      last.moveH(d);
    }
  }
  
  float vFirst(){
    return(((float)(first.x+h-x-h))/((float)(w-2*h)));
  }
  
  float vLast(){
    return(((float)(last.x-h-x))/((float)(w-2*h)));
  }

  void draw(int cBackground, int cFirst, int cLast){
    fill(cBackground);
    noStroke();
    rect(x,y,w,h);
    first.draw(cFirst);
    last.draw(cLast);
  }
}

void prepareScreenStructure(){
  wGUI = width;
  hGUI = 50;
  wScreen = width;
  hScreen = height-hGUI;
  flc = new DoubleSlider(20,15,760,20);
}

void drawGUI(){
  fill(200);
  noStroke();
  rect(5,5,wGUI-10,hGUI-10,5);
  // Drawing elements control
  flc.draw(#9999FF,#5555FF,#5555FF);
  // debug only:
  //debugText("Points: "+MAXPOINTS);
}


void debugText(String s){
  fill(0);
  textSize(12);
  textAlign(CENTER);
  text(s, width/2, hGUI+30);
}


void mousePressed(){
  int tmp;
  tmp = flc.isPressed(mouseX,mouseY);
  println(tmp);
  mxTmp = mouseX;
  myTmp = mouseY;
}

void mouseReleased(){
  flc.release();
}

void mouseDragged(){
  float z;
  if (mouseY>hGUI && reset==false){
    if (keyPressed){
      if (key=='r'){
        rhoY = rhoY + 2.0*(mouseX-mxTmp)/width*PI;
        mxTmp = mouseX;
        rhoX = rhoX + 2.0*(mouseY-myTmp)/width*PI;
        myTmp = mouseY;  
      } else if(key=='s'){
        if (mouseY>myTmp){
          z=1;
        } else if (mouseY<myTmp){
          z=-1;
        } else {
          z=0;
        }
        zoomV = zoomV*(1+0.05*z);
        mxTmp = mouseX;
        myTmp = mouseY;      
      }
    } else {
      //translate
      tx = tx + mouseX-mxTmp;
      mxTmp = mouseX;
      ty = ty + mouseY-myTmp;
      myTmp = mouseY;
    }
  } else {
    flc.moveButton(mouseX-mxTmp);
    mxTmp=mouseX;
    vFirst = flc.vFirst();
    vLast = flc.vLast();
  }
}

void keyPressed(){
  switch (key) {
    case '+':
      reduction+=0.01;
      break;
    case '-':
      reduction-=0.01;
      break;
    case 'q':
      zoomV+=0.1;
      break;
    case 'w':
      zoomV-=0.1;
      break;
    case 'o':
      if (progress==0.0){
        test=true;
        direction=1;
      } else if (progress==1.0) {
        test=true;
        direction=-1;
      }
      break;
    case ' ':
      reset=true;
      break;
  }
  println("Reduction: ",reduction, ", Zoom: ", zoomV);
}