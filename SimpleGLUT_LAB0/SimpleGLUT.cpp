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
	g_model.LoadModel( "data/car.d2" );
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
void render( void ) {
	// clear color and depth buffer
	glClearColor (0.0, 0.0, 0.0, 0.0);
	glClearDepth (1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	
	
	// render state
	glEnable(GL_DEPTH_TEST);

	// modelview matrix
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();

	// draw model
	glLineWidth( 1 );
	glColor3f( 1.0, 1.0, 1.0 );
	g_model.DrawEdges2D();

	// swap back and front buffers
	glutSwapBuffers();
}

//================================
// keyboard input
//================================
void keyboard( unsigned char key, int x, int y ) {
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

	// projection matrix
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
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
	glutKeyboardFunc( keyboard );
	glutTimerFunc( 16, timer, 0 );
	
	// main loop
	glutMainLoop();

	return 0;
}