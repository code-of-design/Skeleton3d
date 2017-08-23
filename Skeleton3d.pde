/*
 Copyright (C) 2014  Thomas Sanchez Lengeling.
 KinectPV2, Kinect for Windows v2 library for processing

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import KinectPV2.KJoint;
import KinectPV2.*;

KinectPV2 kinect;

Skeleton [] skeleton;

KJoint[] joints;

PVector ankleLeft, ankleRight, footLeft, footRight; // 足ベクトル.

// float zVal = 300;
float zVal = 800;
float rotX = PI;

int floor_num = 9; // 床の数.
PVector[] floor = new PVector[floor_num]; // 床ベクトル.
int floor_count = 0; // ループカウンタ.
float floorY = -1.0; // 床のy座標.
float floorR = 0.15; // 床の半径.
 // 床と足の距離.
float ankle_dist_left = 0.0; // 左足かかと.
float ankle_dist_right = 0.0; // 右足かかと.
float foot_dist_left = 0.0; // 左足つまさき.
float foot_dist_right = 0.0; // 右足つまさき.
float dist_th = 0.15; // 床と足の当たり判定の閾値.
int[] floor_state = new int[floor_num]; // 床と足の当たり判定の状態配列.
float floor_stroke_weight = 10.0; // 床pointの重さ.

void setup() {
  size(1024, 768, P3D);
  // size(1920, 1080, P3D); // Kinect color space.

  frameRate(30); // Kinectフレームレート.

  // 床の位置を初期化する.
  for(float z=1.3; z<=1.9; z+=0.3){
    for(float x=-0.45; x<=0.45; x+=0.3){
        floor[floor_count] = new PVector(x+floorR, floorY, z+floorR);
        floor_count++;
    }
  }

  // 床の状態を初期化する.
  for(int i=0; i<floor_num; i++){
    floor_state[i] = 0; // Off.
  }

  println(floor); // 床の位置を表示する.

  kinect = new KinectPV2(this);

  kinect.enableColorImg(true);
  kinect.enableSkeleton(true);
  kinect.enableSkeletonColorMap(true);

  // Enable 3d Skeleton with (x,y,z) position!
  kinect.enableSkeleton3dMap(true);

  kinect.init(); // Kinectを初期化する.
}

void draw() {
  background(0);

  // image(kinect.getColorImage(), 0, 0, 320, 240);
  // image(kinect.getColorImage(), 0, 0, width, height);

  skeleton =  kinect.getSkeleton3d();

  // CameraSpace.
  //translate the scene to the center
  pushMatrix();
  translate(width/2, height/2, 0);
  // translate(width, height, 0);
  scale(zVal);
  rotateX(rotX);

  for (int i = 0; i < skeleton.length; i++) {
    if (skeleton[i].isTracked()) {
      // KJoint[]
      joints = skeleton[i].getJoints();

      // Draw different color for each hand state.
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);

      // Draw body.
      // color col  = getIndexColor(i);
      stroke(0,255,255);
      drawBody(joints);

      // 足ベクトルを取得する.
      ankleLeft = new PVector(joints[KinectPV2.JointType_AnkleLeft].getX(), joints[KinectPV2.JointType_AnkleLeft].getY(), joints[KinectPV2.JointType_AnkleLeft].getZ());
      ankleRight = new PVector(joints[KinectPV2.JointType_AnkleRight].getX(), joints[KinectPV2.JointType_AnkleRight].getY(), joints[KinectPV2.JointType_AnkleRight].getZ());
      footLeft = new PVector(joints[KinectPV2.JointType_FootLeft].getX(), joints[KinectPV2.JointType_FootLeft].getY(), joints[KinectPV2.JointType_FootLeft].getZ());
      footRight = new PVector(joints[KinectPV2.JointType_FootRight].getX(), joints[KinectPV2.JointType_FootRight].getY(), joints[KinectPV2.JointType_FootRight].getZ());

      // 足と床の距離を描画する.
      stroke(255,0,255);
      strokeWeight(0.01); // 距離lineの重さ.
      for(int j=0; j<floor_num; j++){
        // 足と床の距離を取得する.
        ankle_dist_left = sqrt(sq(ankleLeft.x-floor[j].x)+sq(ankleLeft.z-floor[j].z));
        ankle_dist_right = sqrt(sq(ankleRight.x-floor[j].x)+sq(ankleRight.z-floor[j].z));
        foot_dist_left = sqrt(sq(footLeft.x-floor[j].x)+sq(footLeft.z-floor[j].z));
        foot_dist_right = sqrt(sq(footRight.x-floor[j].x)+sq(footRight.z-floor[j].z));

        // ankle_dist_left = PVector.dist(floor[0], ankleLeft);
        // ankle_dist_right = PVector.dist(floor[i], ankleRight);

        // 距離lineを描写する.
        // line(floor[j].x, floor[j].y, floor[j].z, ankleLeft.x, ankleLeft.y, ankleLeft.z);
        // line(floor[j].x, floor[j].y, floor[j].z, footLeft.x, footLeft.y, footLeft.z);
        // line(floor[j].x, floor[j].y, floor[j].z, ankleRight.x, ankleRight.y, ankleRight.z);

        // 足と床の当たり判定.
        if(ankle_dist_left <= dist_th || ankle_dist_right <= dist_th || foot_dist_left <= dist_th || foot_dist_right <= dist_th){
          floor_state[j] = 1; // On.
        }
        else{
          floor_state[j] = 0; // Off.
        }

      }
    }
  }

  // 床の位置を描写する.
  strokeWeight(10); // 床pointの重さ.

  for(int i=0; i<floor_num; i++){
    if(floor_state[i] == 0){
      stroke(255,0,255); // 床pointの色値.
    }
    if(floor_state[i] == 1){ // On.
      stroke(0,0,255); // 床pointの色値.
    }
    point(floor[i].x, floor[i].y, floor[i].z); // 床pointを描画する.
  }

  popMatrix();

  // ColorSpace.
  fill(255, 0, 0);
  textSize(28);
  text("FrameRate: "+int(frameRate), 50, 50); // フレームレートのメタ情報.
  // 床の状態のメタ情報.
  for(int y=0; y<3; y++){
    for(int x=0; x<3; x++){
      stroke(255, 0, 0);
      strokeWeight(2);
      if(floor_state[x+y+(2*y)] == 1){
        fill(255, 0, 0);
        rect(50+(50*x), 100+(50*y), 50, 50);
        fill(0);
        text((x+y+(2*y)+1), 50+(50*x)+15, 100+(50*y)+35);
      }
      else{
        noFill();
        rect(50+(50*x), 100+(50*y), 50, 50);
        fill(255, 0, 0);
        text((x+y+(2*y)+1), 50+(50*x)+15, 100+(50*y)+35);
      }

    }
  }
}

//use different color for each skeleton tracked
color getIndexColor(int index) {
  color col = color(255);
  if (index == 0)
    col = color(255, 0, 0);
  if (index == 1)
    col = color(0, 255, 0);
  if (index == 2)
    col = color(0, 0, 255);
  if (index == 3)
    col = color(255, 255, 0);
  if (index == 4)
    col = color(0, 255, 255);
  if (index == 5)
    col = color(255, 0, 255);

  return col;
}

void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);

  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
}

void drawJoint(KJoint[] joints, int jointType) {
  strokeWeight(2.0f + joints[jointType].getZ()*8);
  point(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
}

void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  strokeWeight(2.0f + joints[jointType1].getZ()*8);
  point(joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}

void drawHandState(KJoint joint) {
  handState(joint.getState());
  strokeWeight(5.0f + joint.getZ()*8);
  point(joint.getX(), joint.getY(), joint.getZ());
}

void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    stroke(0, 255, 0);
    break;
  case KinectPV2.HandState_Closed:
    stroke(255, 0, 0);
    break;
  case KinectPV2.HandState_Lasso:
    stroke(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    stroke(100, 100, 100);
    break;
  }
}
