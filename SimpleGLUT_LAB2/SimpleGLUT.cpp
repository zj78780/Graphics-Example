#include "stdafx.h"

// standard
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <vector>

// glut
#include <GL/glut.h>

// source
#include <math/vec3.h>
#include <model.h>

//================================
// global variables
//================================
// screen size
int g_screenWidth  = 0;
int g_screenHeight = 0;

// frame index
int g_frameIndex = 0;

// model
Model g_model;

//================================
// init
//================================
void init( void ) {
	// init something before main loop...

	// load model
	g_model.LoadModel( "data/cow.d" ); 
}

//================================
// update
//================================
void update( void ) {
	// do something before rendering...
}

//================================
// render
//================================
void drawGrids( float height ) {
	float step = 0.1f;

	int n = 20;

	float r = step * n;

	glBegin( GL_LINES );

	for ( int i = -n; i <= n; i++ ) {
		glVertex3f( i * step, height, -r );
		glVertex3f( i * step, height, +r );
	}

	for ( int i = -n; i <= n; i++ ) {
		glVertex3f( -r, height, i * step );
		glVertex3f( +r, height, i * step );
	}

	glEnd();
}

void render( void ) {
	// clear color and depth buffer
	glClearColor (0.0, 0.0, 0.0, 0.0);
	glClearDepth ( 1.0 );
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	
	
	// enable depth test
	glEnable( GL_DEPTH_TEST );

	// modelview matrix <------------------------------------------
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	gluLookAt(
		2, 2, 2, // eye
		0, 0, 0, // center
		0, 1, 0  // up
	);

	// draw grids
	glLineWidth( 1 );
	glColor4f( 0.2f, 0.2f, 0.5f, 1.0f );
	drawGrids( -0.9f );

	// draw model
	glLineWidth( 1 );
	glColor4f( 1.0, 1.0, 1.0, 1.0 );
	g_model.DrawEdges();

	// swap back and front buffers
	glutSwapBuffers();
}

//================================
// keyboard input
//================================
void key_press( unsigned char key, int x, int y ) {
	switch (key) {
	case 'w':
		break;
	case 'a':
		break;
	case 's':          
		break;
	case 'd':
		break;
	default:
		break;
    }
}
 
void special_key( int key, int x, int y ) {
	switch (key) {
	case GLUT_KEY_RIGHT: //right arrow
		break;
	case GLUT_KEY_LEFT: //left arrow
		break;
	default:      
		break;
	}
}

//================================
// reshape : update viewport and projection matrix when the window is resized
//================================
void reshape( int w, int h ) {
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


//================================
// timer : triggered every 16ms ( about 60 frames per second )
//================================
void timer( int value ) {
	// increase frame index
	g_frameIndex++;

	update();
	
	// render
	glutPostRedisplay();

	// reset timer
	glutTimerFunc( 16, timer, 0 );
}

//================================
// main
//================================
int main( int argc, char** argv ) {
	// create opengL window
	glutInit( &argc, argv );
	glutInitDisplayMode( GLUT_DOUBLE | GLUT_RGB |GLUT_DEPTH );
	glutInitWindowSize( 600, 600 ); 
	glutInitWindowPosition( 100, 100 );
	glutCreateWindow( argv[0] );

	// init
	init();
	
	// set callback functions
	glutDisplayFunc( render );
	glutReshapeFunc( reshape );
	glutKeyboardFunc( key_press ); 
	glutSpecialFunc( special_key );
	glutTimerFunc( 16, timer, 0 );
	
	// main loop
	glutMainLoop();

	return 0;
}