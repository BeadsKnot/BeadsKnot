package com.example.aharalab2017_a.beadsknot;

import android.app.Activity;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Point;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
//import android.os.Environment;
import android.os.ParcelFileDescriptor;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;

import android.view.Display;
import android.view.MotionEvent;
import android.view.Menu;
import android.view.MenuItem;

import java.io.FileDescriptor;
import java.io.IOException;

public class MainActivity extends AppCompatActivity {
    //Paint paint;
    DrawableView v;
    Bitmap bitmap;
    double drag_startX = 0.0;
    double drag_startY = 0.0;

    private static final int RESULT_PICK_IMAGEFILE = 1001;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getImageFromGallery();

        v=new DrawableView(getApplicationContext());
        setContentView(v);
    }

    protected void getImageFromGallery(){
        // ギャラリーから画像を選ばせる
        // すべてのマシン・バージョンに対応するには加筆する必要がある。
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("image/*");
        startActivityForResult(intent, RESULT_PICK_IMAGEFILE);
    }

    @Override//再定義
    public boolean onTouchEvent(MotionEvent e){
        double wid = v._r - v._l;
        double hei = v._b - v._t;
        double rate;
        if(wid>hei) rate = 1080/wid; else rate = 1080/hei;
        double eX = e.getX()/rate + v._l;
        double eY = (e.getY()-55)/rate + v._t;

        //Log.d("CHECK","onTouch-move:" + eX + "," + eY);
        if(e.getAction()==MotionEvent.ACTION_MOVE){
            if(v.selected_node != null && drag_startX != 0.0 && drag_startY != 0.0){
                double minimum = Math.hypot(eX-drag_startX, eY-drag_startY);
                boolean moveOK=true;
                for(Node ali:v.nodes){
                    if(ali != v.selected_node){
                        double D = Math.hypot(eX-ali.x, eY-ali.y);
                        if (D <= minimum) {
                            moveOK=false;
                            break;
                        }
                    }
                }
                if(moveOK) {
                    v.setX((float) eX);
                    v.setY((float) eY);
                    v.invalidate();
                }
                //Log.d("actionMove",""+moveOK);
            }
        } else if(e.getAction()==MotionEvent.ACTION_DOWN){
            Log.d("CHECK","onTouch-down:" + eX + "," + eY);
            if(e.getY() > 1080){
                getImageFromGallery();
            } else {
                double miniD=1000000;
                v.selected_node = null;
                for(Node ali:v.nodes){
                    double D = Math.hypot(eX-ali.x, eY-ali.y);
                    if (D <= miniD && D < 30.0) {
                        miniD=D;
                        v.selected_node = ali;
                        v.selected_node.radius=50;
                        drag_startX = ali.x;
                        drag_startY = ali.y;
                        //break;
                    }
                }
                if(v.selected_node != null){
                    v.selected_node.drawOn = true;
                } else  {
                    Edge thisEdge = null;
                    double minXx = v._r;
                    for (Edge edge : v.edges) {
                        double xx = edge.getXIntersectionWithBezier(eX, eY, v.nodes);
                        if (-9990 < xx && xx < minXx) {
                            minXx = xx;
                            thisEdge = edge;
                        }
                    }
                    for (Node a : v.nodes) {
                        a.drawOn = false;
                    }
                    if (thisEdge != null) {
                        thisEdge.setDrawOn(v.nodes, v.edges);
                    } else {
                        Log.d("getArea", "null");
                    }
                }
                v.invalidate();
            }
        } else if(e.getAction()==MotionEvent.ACTION_UP){
            if(v.selected_node != null){
                v.selected_node.radius=20;
                v.selected_node = null;
                drag_startX = drag_startY = 0.0;
            }
        }
        return false;
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        return id == R.id.action_settings || super.onOptionsItemSelected(item);
//        if (id == R.id.action_settings) {
//            return true;
//        }
//        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent resultData) {
        if (requestCode == RESULT_PICK_IMAGEFILE && resultCode == Activity.RESULT_OK) {
            Uri uri;
            if (resultData != null) {
                uri = resultData.getData();
                Log.i("", "Uri: " + uri.toString());

                try {
                    bitmap = getBitmapFromUri(uri);
                    Display display = getWindowManager().getDefaultDisplay();
                    Point pt = new Point();
                    display.getSize(pt);// 画面サイズ取得
                    v.nodes.clear();
                    v.edges.clear();
                    v.addSizeAndBmp(pt, bitmap);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }


    private Bitmap getBitmapFromUri(Uri uri) throws IOException {
            ParcelFileDescriptor parcelFileDescriptor =
                    getContentResolver().openFileDescriptor(uri, "r");
            FileDescriptor fileDescriptor = parcelFileDescriptor.getFileDescriptor();
            Bitmap image = BitmapFactory.decodeFileDescriptor(fileDescriptor);
            parcelFileDescriptor.close();
            return image;
    }


}

