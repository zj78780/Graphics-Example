
/**********************************************************************
 *
 *  Texture map loading (Mac)
 *  Lab 3
 *  Jing Zhang 4/23/2017
 *
 **********************************************************************/

#ifdef __APPLE__
#include <OpenGL/OpenGL.h>
#include <Glut/glut.h>
#include <GL/glut.h>
#import <Foundation/Foundation.h>
#import <AppKit/NSImage.h>
#else
#include <GL/glut.h>
#endif

#include <string>
#include <math.h>
#include <iostream>
#include <fstream>
#include <stdio.h>
#include <vector>

// source
#include <math/vec3.h>
#include <model.h>


using namespace std;
/* ascii codes for special keys */
#define ESCAPE 27

/**********************************************************************
 * Configuration
 **********************************************************************/

#define INITIAL_WIDTH 1000
#define INITIAL_HEIGHT 800
#define INITIAL_X_POS 200
#define INITIAL_Y_POS 110

#define WINDOW_NAME     "Lab 3 : Texture map"

// Change this to the directory where you have the .d2 files on your
// computer, or put the files in your programs default start up directory.
#define RESOURCE_DIR   "/Users/OwenZhang/Documents/Xcode_project/LoadTexture/resources/"

/**********************************************************************
 * Globals
 **********************************************************************/

// wall properties
GLuint m_wall_texture_id[3];
float depth = 0;
float height =0;

// screen size
int g_screenWidth  = 0;
int g_screenHeight = 0;

// frame index
int g_frameIndex = 0;

// model
Model g_model[3];

// model properties
GLfloat loc_cow[2][3]; //two cows' translate location
int rot_x = 0,rot_y = 0,rot_z = 0; //rotate variables
float eye_x=17.5, eye_y=6.5, eye_z=1; //lookat location
bool mouse_state = false;
int loc_x = 0, loc_y = 0; //mouse location in screen
float mod_x = 2, mod_y = 0, mod_z = -1.5, scale = 1.0; //controled cow's translate location

//light properties
GLfloat pos_x=1.0f;//postion of light1
GLfloat pos_y=3.6f;
GLfloat pos_z=-2.6f;

GLfloat pos_x_s=-6.0f;//postion of light0
GLfloat pos_y_s=3.0f;
GLfloat pos_z_s=6.0f;

GLfloat ambientLight[]={0.0f,0.0f,0.0f,1.0f};
GLfloat diffuseLight[]={1.0f,1.0f,1.0f,1.0f};
GLfloat specularLight[]={1.0f,1.0f,1.0f,1.0f};

GLfloat lightPos_0[]={pos_x_s,pos_y_s,pos_z_s,1.0f};  //postion of light0
GLfloat lightPos_1[]={pos_x,pos_y,pos_z,1.0f};  //postion of light1


/**********************************************************************
 * Set the new size of the window
 **********************************************************************/

void resize_scene(GLsizei w, GLsizei h)
{
    // screen size
    g_screenWidth  = w;
    g_screenHeight = h;
    
    // viewport
    glViewport( 0, 0, (GLsizei)w, (GLsizei)h );
    
    // projection matrix <------------------------------------------
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();
    gluPerspective( 45.0f, (float)w / (float)h, 0.1f, 100.0f );
    
}

/**********************************************************************
 * Load an image and return a texture id or 0 on failure
 **********************************************************************/
GLuint getTextureFromFile(const char *fname)
{
    NSString *str = [[NSString alloc] initWithCString:fname];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:str];
    
    // error loading image
    if (![image isValid])
        return 0;
    
    int texformat = GL_RGB;
    
    // convert our NSImage to a NSBitmapImageRep
    NSBitmapImageRep * imgBitmap =[ [ NSBitmapImageRep alloc ]initWithData: [ image TIFFRepresentation ] ];
    
    //[ imgBitmap retain ];
    // examine & remap format
    switch( [ imgBitmap samplesPerPixel ] )        
    {
        case 4:texformat = GL_RGBA;
            break;
        case 3:texformat = GL_RGB;
            break;
        case 2:texformat = GL_LUMINANCE_ALPHA;
            break;
        case 1:texformat = GL_LUMINANCE;
            break;
        default:
            break;
    }
    
    
    GLuint tex_id;
    
    glGenTextures (1, &tex_id);
    glBindTexture(GL_TEXTURE_2D, tex_id);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, texformat, [image size].width, [image size].height, 
                 0, texformat, GL_UNSIGNED_BYTE, [ imgBitmap bitmapData ]);
    
    
    return tex_id;
}


/**********************************************************************
 * any program initialization (set initial OpenGL state, 
 **********************************************************************/
void init()
{
    // Load any models you will need during initialization
    string ifile_wall = RESOURCE_DIR + string("wall.png");
    string ifile_ceiling = RESOURCE_DIR + string("wood_ceiling.png");
    string ifile_floor = RESOURCE_DIR + string("grass.png");
    
    m_wall_texture_id[0] = getTextureFromFile(ifile_floor.c_str());
    m_wall_texture_id[1] = getTextureFromFile(ifile_wall.c_str());
    m_wall_texture_id[2] = getTextureFromFile(ifile_ceiling.c_str());
    
    // load model
    for(int i=0;i<3;i++){
        g_model[i].LoadModel( "/Users/OwenZhang/Documents/Xcode_project/LoadTexture/resources/cow.d" );
        g_model[i].Scale(1.1f);
    }
    // init two cows' location
    loc_cow[0][0]=0;
    loc_cow[0][1]=0;
    loc_cow[0][2]=-1.5;
    loc_cow[1][0]=0;
    loc_cow[1][1]=0;
    loc_cow[1][2]=3.5;
    //init light0 on/light1 off
    glEnable(GL_LIGHT0);
    

}





/**********************************************************************
 * The main drawing functions. 
 **********************************************************************/


void draw_scene(void)
{
    
    depth = 10; //wall width
    height = 15; //wall height
    
    // clear color and depth buffer
    glClearColor (0.0, 0.0, 0.0, 0.0);
    glClearDepth ( 1.0 );
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    /*-----------------------------------------------------------------*/
    
    
    // enable depth test
    glEnable( GL_DEPTH_TEST );
    
    // modelview matrix <------------------------------------------
    glMatrixMode( GL_MODELVIEW );
    glLoadIdentity();
    gluLookAt(
              eye_x, eye_y, eye_z, // eye
              0, 0, 0, // center
              0, 1, 0  // up
              );
    
    
    
    //light
    glEnable(GL_LIGHTING);
    
    glLightfv(GL_LIGHT0,GL_AMBIENT,ambientLight);
    glLightfv(GL_LIGHT0,GL_DIFFUSE,diffuseLight);
    glLightfv(GL_LIGHT0,GL_SPECULAR,specularLight);
    glLightfv(GL_LIGHT0,GL_POSITION,lightPos_0);
    glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION, 1.0);
    glLightf(GL_LIGHT0, GL_LINEAR_ATTENUATION, 0.001);
    glLightf(GL_LIGHT0, GL_QUADRATIC_ATTENUATION, 0.005);
    
    lightPos_1[0]=pos_x;  //set postion of light1
    lightPos_1[1]=pos_y;
    lightPos_1[2]=pos_z;
    lightPos_1[3]=1.0f;
    
    glLightfv(GL_LIGHT1,GL_AMBIENT,ambientLight);
    glLightfv(GL_LIGHT1,GL_DIFFUSE,diffuseLight);
    glLightfv(GL_LIGHT1,GL_SPECULAR,specularLight);
    glLightfv(GL_LIGHT1,GL_POSITION,lightPos_1);
    glLightf(GL_LIGHT1, GL_CONSTANT_ATTENUATION, 1.0);
    glLightf(GL_LIGHT1, GL_LINEAR_ATTENUATION, 0.001);
    glLightf(GL_LIGHT1, GL_QUADRATIC_ATTENUATION, 0.005);
    
    
    glShadeModel(GL_SMOOTH);
    glEnable(GL_CULL_FACE);
    
    //draw floor
    glColor4f( 1.0f, 1.0f, 1.0f, 1.0f );
    glEnable(GL_TEXTURE_2D);
    
    glBindTexture(GL_TEXTURE_2D, m_wall_texture_id[0]);

    glBegin(GL_QUADS);
    
    glNormal3f(-0.577,0.577,-0.577);
    glTexCoord2f(0.0f, 0.0f);
    glVertex3f(depth, -1.0f, depth);
    
    glNormal3f(-0.577,0.577,0.577);
    glTexCoord2f(4.0f, 0.0f);
    glVertex3f(depth, -1.0f, -depth);
    
    glNormal3f(0.577,0.577,0.577);
    glTexCoord2f(4.0f, 4.0f);
    glVertex3f(-depth, -1.0f, -depth);
    
    glNormal3f(0.577,0.577,-0.577);
    glTexCoord2f(0.0f, 4.0f);
    glVertex3f(-depth, -1.0f, depth);
    
    glEnd();
    
    //draw walls_1
    glColor4f( 1.0f, 1.0f, 1.0f, 1.0f );
    glEnable(GL_TEXTURE_2D);
    
    glBindTexture(GL_TEXTURE_2D, m_wall_texture_id[1]);
    glBegin(GL_QUADS);
    
    glNormal3f(0.577,-0.577,-0.577);
    glTexCoord2f(0.0f, 0.0f);
    glVertex3f(-depth, height, depth);
    
    glNormal3f(-0.577,-0.577,-0.577);
    glTexCoord2f(1.0f, 0.0f);
    glVertex3f(depth, height, depth);
    
    glNormal3f(-0.577,0.577,-0.577);
    glTexCoord2f(1.0f, 1.0f);
    glVertex3f(depth, -1.0f, depth);
    
    glNormal3f(0.577,0.577,-0.577);
    glTexCoord2f(0.0f, 1.0f);
    glVertex3f(-depth, -1.0f, depth);
    
    glEnd();
    
    
    //draw walls_2
    glColor4f( 1.0f, 1.0f, 1.0f, 1.0f );
    glEnable(GL_TEXTURE_2D);
    
    glBindTexture(GL_TEXTURE_2D, m_wall_texture_id[1]);
    glBegin(GL_QUADS);
    
    glNormal3f(-0.577,-0.577,-0.577);
    glTexCoord2f(0.0f, 0.0f);
    glVertex3f(depth, height, depth);
    
    glNormal3f(-0.577,-0.577,0.577);
    glTexCoord2f(1.0f, 0.0f);
    glVertex3f(depth, height, -depth);
    
    glNormal3f(-0.577,0.577,0.577);
    glTexCoord2f(1.0f, 1.0f);
    glVertex3f(depth, -1.0f, -depth);
    
    glNormal3f(-0.577,0.577,-0.577);
    glTexCoord2f(0.0f, 1.0f);
    glVertex3f(depth, -1.0f, depth);
    
    glEnd();
    
    
    //draw walls_3
    glColor4f( 1.0f, 1.0f, 1.0f, 1.0f );
    glEnable(GL_TEXTURE_2D);
    
    
    glBindTexture(GL_TEXTURE_2D, m_wall_texture_id[1]);
    glBegin(GL_QUADS);
    
    glNormal3f(-0.577,-0.577,0.577);
    glTexCoord2f(0.0f, 0.0f);
    glVertex3f(depth, height, -depth);
    
    glNormal3f(0.577,-0.577,0.577);
    glTexCoord2f(1.0f, 0.0f);
    glVertex3f(-depth, height, -depth);
    
    glNormal3f(0.577,0.577,0.577);
    glTexCoord2f(1.0f, 1.0f);
    glVertex3f(-depth, -1.0f, -depth);
    
    glNormal3f(-0.577,0.577,0.577);
    glTexCoord2f(0.0f, 1.0f);
    glVertex3f(depth, -1.0f, -depth);
    
    glEnd();
    
    
    //draw walls_4
    glColor4f( 1.0f, 1.0f, 1.0f, 1.0f );
    glEnable(GL_TEXTURE_2D);
    
    glBindTexture(GL_TEXTURE_2D, m_wall_texture_id[1]);
    glBegin(GL_QUADS);
    
    glNormal3f(0.577,-0.577,0.577);
    glTexCoord2f(0.0f, 0.0f);
    glVertex3f(-depth, height, -depth);
    
    glNormal3f(0.577,-0.577,-0.577);
    glTexCoord2f(1.0f, 0.0f);
    glVertex3f(-depth, height, depth);
    
    glNormal3f(0.577,0.577,-0.577);
    glTexCoord2f(1.0f, 1.0f);
    glVertex3f(-depth, -1.0f, depth);
    
    glNormal3f(0.577,0.577,0.577);
    glTexCoord2f(0.0f, 1.0f);
    glVertex3f(-depth, -1.0f, -depth);
  
    glEnd();
    
    
    //draw ceiling
    glColor4f( 1.0f, 1.0f, 1.0f, 1.0f );
    glEnable(GL_TEXTURE_2D);
    
    glBindTexture(GL_TEXTURE_2D, m_wall_texture_id[2]);
    glBegin(GL_QUADS);
    
    glNormal3f(0.577,-0.577,-0.577);
    glTexCoord2f(0.0f, 1.0f);
    glVertex3f(-depth, height, depth);
    
    glNormal3f(0.577,-0.577,0.577);
    glTexCoord2f(1.0f, 1.0f);
    glVertex3f(-depth, height, -depth);
    
    glNormal3f(-0.577,-0.577,0.577);
    glTexCoord2f(1.0f, 0.0f);
    glVertex3f(depth, height, -depth);
    
    glNormal3f(-0.577,-0.577,-0.577);
    glTexCoord2f(0.0f, 0.0f);
    glVertex3f(depth, height, depth);

    glEnd();
    
    glDisable(GL_TEXTURE_2D);
    
    glDisable(GL_LIGHTING);
    
    //draw light0(stable) sphere
    glColor4f( 1.0f, 0.1f, 0.0f, 1.0f );
    glPushMatrix();
    glTranslatef(pos_x_s,pos_y_s,pos_z_s);
    glutSolidSphere(0.2, 20, 20);
    glPopMatrix();
    
    //draw light1(movable) sphere
    glColor4f( 1.0f, 1.0f, 0.0f, 1.0f );
    glPushMatrix();
    glTranslatef(pos_x,pos_y,pos_z);
    glutSolidSphere(0.2, 20, 20);
    glPopMatrix();
    
    glEnable(GL_LIGHTING);
    
    //material of model setup
    glEnable(GL_COLOR_MATERIAL);
    glColorMaterial(GL_FRONT,GL_AMBIENT_AND_DIFFUSE);
    
    // draw model
    glLineWidth( 1 );
    glColor4f( 0.8, 0.8, 0.8, 1.0 );
    //draw two cows
    glPushMatrix();
    for(int i=0;i<2;i++){
        glTranslatef(loc_cow[i][0], loc_cow[i][1], loc_cow[i][2]);
        g_model[i].ColorFill(); //fill triangles with color
    }
    //draw controled cow
    glColor4f( 0.8, 0.6, 0.6, 1.0 );
    glTranslatef(mod_x, mod_y, mod_z);
    glRotatef(rot_x, rot_y, rot_z, 0);
    g_model[2].ColorFill(); //fill triangles with color
    glPopMatrix();
    
    //glDisable(GL_COLOR_MATERIAL);
    // swap back and front buffers
    glutSwapBuffers();
    
    //show location of viewport and light1
    printf("viewport loc: %.3f  %.3f  %.3f\n",eye_x,eye_y,eye_z);
    printf("light_1 loc: %.3f  %.3f  %.3f\n",pos_x,pos_y,pos_z);
    

}

/**********************************************************************
 * this function is called whenever a key is pressed
 **********************************************************************/
void key_press(unsigned char key, int x, int y) 
{
    //camera change
    if (key == 0x1B)// ESE exit
        exit(0);
    if (key == 'w' || key == 'W')
        eye_y += 0.5f;
    if (key == 's' || key == 'S')
        eye_y -= 0.5f;
    if (key == 'a' || key == 'A')
        eye_x -= 0.5f;
    if (key == 'd' || key == 'D')
        eye_x += 0.5f;
    if (key == 'q' || key == 'Q')
        eye_z += 0.5f;
    if (key == 'e' || key == 'E')
        eye_z -= 0.5f;
    
    //model rotate
    if (key == 'r' || key == 'R')
        rot_x -= 5;
    if (key == 't' || key == 'T')
        rot_x += 5;
    if (key == 'f' || key == 'F')
        rot_y -= 10;
    if (key == 'g' || key == 'G')
        rot_y += 10;
    if (key == 'v' || key == 'V')
        rot_z -= 10;
    if (key == 'b' || key == 'B')
        rot_z += 10;
    
    //model scale
    if (key == 'z' || key == 'Z')
        g_model[2].Scale(1 * 1.1);
    if (key == 'c' || key == 'C')
        g_model[2].Scale(1 / 1.1);
    
    //light1 postion change
    if (key == 'u' || key == 'U')
        pos_y += 0.8f;
    if (key == 'j' || key == 'J')
        pos_y -= 0.8f;
    if (key == 'h' || key == 'H')
        pos_x -= 0.8f;
    if (key == 'k' || key == 'K')
        pos_x += 0.8f;
    if (key == 'y' || key == 'Y')
        pos_z += 0.8f;
    if (key == 'i' || key == 'I')
        pos_z -= 0.8f;
    
    //light1 turn on/turn off
    if (key == '[' || key == '{')
        glEnable(GL_LIGHT1);
    if (key == ']' || key == '}')
        glDisable(GL_LIGHT1);
    
    //light0 turn on/turn off
    if (key == ',' || key == '<')
        glEnable(GL_LIGHT0);
    if (key == '.' || key == '>')
        glDisable(GL_LIGHT0);
}

/**********************************************************************
 * this function is called whenever the mouse is moved
 **********************************************************************/

void handle_mouse_motion(int x, int y)
{
    // If you do something here that causes a change to what the user
    // would see, call glutPostRedisplay to force a redraw
    //glutPostRedisplay();
    
    //when mouse press down and move, cow rotates
    if (mouse_state) {
        int sub_x = loc_x - x;
        int sub_y = loc_y - y;
        if(sub_x>=0&&sub_y>=0){rot_x+=5;rot_z-=5;};
        if(sub_x>=0&&sub_y<0){rot_x+=5;rot_y-=5;};
        if(sub_x<0&&sub_y>=0){rot_x-=5;rot_y+=5;rot_z-=5;};
        if(sub_x<0&&sub_y<0){rot_x-=5;rot_y-=5;rot_z-=5;};
    }
}

/**********************************************************************
 * this function is called whenever a mouse button is pressed or released
 **********************************************************************/

void handle_mouse_click(int btn, int state, int x, int y)
{
//    switch (btn) {
//        case GLUT_LEFT_BUTTON:
//            break;
//    }
    // mouse state change when press down
    if (state == GLUT_DOWN)
    {
        mouse_state = true;
        loc_x = x; loc_y = y;
    }
    else if (state == GLUT_UP) mouse_state = false;
}

/**********************************************************************
 * this function is called for non-standard keys like up/down/left/right
 * arrows.
 **********************************************************************/
void special_key(int key, int x, int y)
{
    //model translate
    switch (key) {
        case GLUT_KEY_RIGHT: mod_x += 0.1f;//right arrow
            break;
        case GLUT_KEY_LEFT: mod_x -= 0.1f;//left arrow
            break;
        case GLUT_KEY_UP: mod_z -= 0.1f;//up arrow
            break;
        case GLUT_KEY_DOWN: mod_z += 0.1f;//down arrow
            break;
        default:
            break;
    }
}

void timer( int value ) {
    // increase frame index
    g_frameIndex++;
    
    
    // render
    glutPostRedisplay();
    
    // reset timer
    glutTimerFunc( 16, timer, 0 );
}


int main(int argc, char * argv[]) 
{  
    
  	/* Initialize GLUT */
    glutInit(&argc, argv);  
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);  
    glutInitWindowSize(INITIAL_WIDTH, INITIAL_HEIGHT);  
    glutInitWindowPosition(INITIAL_X_POS, INITIAL_Y_POS);  
    glutCreateWindow(WINDOW_NAME);
    
    
    /* OpenGL and other program initialization */
    init();
    
    /* Register callback functions */
	glutDisplayFunc(draw_scene);     
    glutReshapeFunc(resize_scene);       //Initialize the viewport when the window size changes.
    glutKeyboardFunc(key_press);         //handle when the key is pressed
    glutMouseFunc(handle_mouse_click);   //check the Mouse Button(Left, Right and Center) status(Up or Down)
    glutMotionFunc(handle_mouse_motion); //Check the Current mouse position when mouse moves
	glutSpecialFunc(special_key);
    glutTimerFunc( 16, timer, 0 );         //Special Keyboard Key fuction(For Arrow button and F1 to F10 button)
    
    
    
    /* Enter event processing loop */
    glutMainLoop();  
    
    return 1;
}


