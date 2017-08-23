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

PVector ankleLeft, footLeft, ankleRight; // 足ベクトル.

// float zVal = 300;
float zVal = 800;
float rotX = PI;

PVector[] floor = new PVector[9]; // 床ベクトル.
int floor_num = 0; // ループカウンタ.

float floorY = -0.7; // 床の位置.
float floorR = 0.15; // 床の半径.
float ankle_dist_left = 0.0; // 床と足の距離.
float foot_dist_left = 0.0;
float ankle_dist_right = 0.0;
float dist_th = 0.15; // 床と足の衝突判定.
float floor_stroke_weight = 10.0;

void setup() {
  size(1024, 768, P3D);
  // size(1920, 1080, P3D); // Kinect color space.

  frameRate(30); // Kinectフレームレート.

  // 床の位置を初期化する.
  for(float z=1.3; z<=1.9; z+=0.3){
    for(float x=-0.45; x<=0.45; x+=0.3){
        floor[floor_num] = new PVector(x+floorR, floorY, z+floorR);
        floor_num++;
    }
  }
  println(floor);

  kinect = new KinectPV2(this);

  kinect.enableColorImg(true);
  kinect.enableSkeleton(true);
  kinect.enableSkeletonColorMap(true);

  // Enable 3d Skeleton with (x,y,z) position!
  kinect.enableSkeleton3dMap(true);

  kinect.init();
}

void draw() {
  background(0);

  // image(kinect.getColorImage(), 0, 0, 320, 240);
  // image(kinect.getColorImage(), 0, 0, width, height);

  skeleton =  kinect.getSkeleton3d();

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

      //draw different color for each hand state
      drawHandState(joints[KinectPV2.JointType_HandRight]);
      drawHandState(joints[KinectPV2.JointType_HandLeft]);

      //Draw body
      // color col  = getIndexColor(i);
      stroke(0,255,255);
      drawBody(joints);

      // 足ベクトルを取得する.
      ankleLeft = new PVector(joints[KinectPV2.JointType_AnkleLeft].getX(), joints[KinectPV2.JointType_AnkleLeft].getY(), joints[KinectPV2.JointType_AnkleLeft].getZ());
      footLeft = new PVector(joints[KinectPV2.JointType_FootLeft].getX(), joints[KinectPV2.JointType_FootLeft].getY(), joints[KinectPV2.JointType_FootLeft].getZ());
      ankleRight = new PVector(joints[KinectPV2.JointType_AnkleRight].getX(), joints[KinectPV2.JointType_AnkleRight].getY(), joints[KinectPV2.JointType_AnkleRight].getZ());

      // 足と床の距離を描画する.
      strokeWeight(0.01);
      // for(int j=0; j<9; j++){
        stroke(255,0,255);

        // ankle_dist_left = PVector.dist(floor[0], ankleLeft);
        // ankle_dist_right = PVector.dist(floor[i], ankleRight);

        // 足と床の距離を取得する.
        ankle_dist_left = sqrt(sq(ankleLeft.x-floor[0].x)+sq(ankleLeft.z-floor[0].z));
        foot_dist_left = sqrt(sq(footLeft.x-floor[0].x)+sq(footLeft.z-floor[0].z));

        line(floor[0].x, floor[0].y, floor[0].z, ankleLeft.x, ankleLeft.y, ankleLeft.z);
        line(floor[0].x, floor[0].y, floor[0].z, footLeft.x, footLeft.y, footLeft.z);

        // line(floor[j].x, floor[j].y, floor[j].z, ankleLeft.x, ankleLeft.y, ankleLeft.z);
        // line(floor[j].x, floor[j].y, floor[j].z, ankleRight.x, ankleRight.y, ankleRight.z);
      // }

    }
  }

  // 床の位置を描写する.
  stroke(255,0,255);
  strokeWeight(10);
  if(ankle_dist_left <= dist_th || foot_dist_left <= dist_th){
    stroke(0,0,255);
  }
  for(int i=0; i<9; i++){
    point(floor[i].x, floor[i].y, floor[i].z);
  }

  popMatrix();

  fill(255, 0, 0);
  textSize(48);
  // text(frameRate, 50, 50);
  text(ankle_dist_left+"\n"+foot_dist_left, 50, 100);
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
