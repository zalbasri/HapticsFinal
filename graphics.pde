 
import processing.serial.*;
 
int twoD_mode = 0;
 
Serial myPort;        // The serial port
String val;
String mass_pos;
String handle_pos;
float wall_pos = 0;
float prev_wall_pos = 0;
float user_pos = 0;
float prev_user_pos = 0;
float anchor_pos = 0.005;
float pixel_wall_loc = 0;
float pixel_anchor_pos = 0;
float pixel_ball_width = 20;
float pixel_user_pos = 0;
String[] list;
int key_press = 0;
int char_position_x = 500;//300;      //character position in pixels, x coordinate
int char_position_y = 500;//300;      //character position in pixels, y coordinate
float char_theta = 0;           //character facing direction, horizontal is 0
int pixel_stride_length = 4;  //character speed controller, sets the number of strides the character moves every loop
float theta_stride_length = 0.02*PI;
static int screen_size_x = 600;
static int screen_size_y = 600;
int num_walls = 16;
int wall_width = floor(screen_size_x/num_walls);  // wall width
boolean orb_not_generated = true;
boolean win = false;
int orb_position_x = 0; 
int orb_position_y = 0;
int orb_distance_x;  //distance to orb in x direction
int orb_distance_y;  //distance to orb in y direction
int orb_distance;    //manhattan distance to orb
 
 
int[][] wall_array = {  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
                     {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                     {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
                     {1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1},
                     {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
                     {1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
                     {1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1},
                     {1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
                     {1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
                     {1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                     {1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1},
                     {1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
                     {1, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
                     {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                     {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
                     {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}};
 
 
 
void settings() {
  size(screen_size_x, screen_size_y);
}
 
void setup () {
  println(Serial.list());
  String portName = Serial.list()[6]; //change the 0 to a 1 or 2 etc. to match your port
  println(portName);
  myPort = new Serial(this, portName, 115200); //make sure baud rate matches Arduino
  delay(1000);
  background(0);      // set inital background:
  hint(ENABLE_STROKE_PURE);
}
 
void keyPressed(){
  if (key == CODED){
    if (keyCode == UP){
     key_press = 1;
    }
    else if (keyCode == DOWN){
     key_press = 2;
    }
    else if (keyCode == LEFT){
     key_press = 3;
    }
    else if (keyCode == RIGHT){
     key_press = 4;
    }
  }
}
 
 
 
 
  
void draw () {
  // everything happens in the serialEvent()
  background(0); //uncomment if you want to control a ball
  stroke(127,34,255);     //stroke color
  strokeWeight(2);        //stroke wider
  
  print(" key pressed: ");
  print(key_press);
  print(" theta :");
  print(char_theta);
  print(" position x:");
  print(char_position_x);
  print(" position y:");
  print(char_position_y);
  print("\n");
  
  //generate the point where the orb is
  while(orb_not_generated == true){
    orb_position_x = 1;floor(random(0,num_walls));
    orb_position_y = 1;floor(random(0,num_walls));
    //check for walls
    if (wall_array[orb_position_y][orb_position_x] == 0){
      orb_not_generated = false;}
  }
 
  println(orb_position_x);
  println(orb_position_y);
  
  //set position before checking for collisions
  int temp_position_x = char_position_x;
  int temp_position_y = char_position_y;
 
  
  if (key_press == 1)
  {
    temp_position_x = char_position_x + floor(pixel_stride_length*cos(char_theta));
    temp_position_y = char_position_y + floor(pixel_stride_length*sin(char_theta));
  }
  else if (key_press == 2)
  {
    temp_position_x = char_position_x - floor(pixel_stride_length*cos(char_theta));
    temp_position_y = char_position_y - floor(pixel_stride_length*sin(char_theta));
  }
  else if (key_press == 3)
  {
    char_theta = char_theta - theta_stride_length;
  }
  else if (key_press == 4)
  { 
    char_theta = char_theta + theta_stride_length;
  } 
    
  //check for collisions with the walls
  int i = 0;
  int collision_flag = 0;
  while (i < num_walls)
  {
    int j = 0;
    while (j < num_walls)
    {
      if (wall_array[i][j] == 1)
    {
      if ((temp_position_x >= j*wall_width) && (temp_position_x <= (j+1)*wall_width))
        {
          if ((temp_position_y >= i*wall_width) && (temp_position_y <= (i+1)*wall_width))
              collision_flag = 1;
        }
    }
    
      j += 1;
    }
    i += 1;
  }
  
  if (collision_flag == 0)
  {
    char_position_x = temp_position_x;
    char_position_y = temp_position_y;
  }
  
  // check for outer boundary collisions
  if (char_position_x > screen_size_x)
  {
    char_position_x = screen_size_x;
  }
  else if (char_position_x < 0)
  {
    char_position_x = 0;
  }
  else if (char_position_y > screen_size_y)
  {
    char_position_y = screen_size_y;
  }
  else if (char_position_y < 0)
  {
    char_position_y = 0;
  }
  
  int grid_x = floor(char_position_x/wall_width); //which cell is the player in the X direction?
  int grid_y = floor(char_position_y/wall_width); //which cell is the player in the Y direction?
  
 
  //check win
  
  if ((grid_x - orb_position_x == 0) && (grid_y - orb_position_y == 0)){
    win = true;}
    
  if(win == true){
    println("you've found the orb!");}
    
  
  //distance
  orb_distance_x = abs(grid_x - orb_position_x);
  orb_distance_y = abs(grid_y - orb_position_y);
  orb_distance = orb_distance_x + orb_distance_y;
  
  myPort.write(Integer.toString(orb_distance)); 
  myPort.write('\n');
  
  print("\nOrb distance x :");
  print(orb_distance_x);
  print("\tOrb distance y :");
  print(orb_distance_y);
  print("\tOrb distance :");
  print(orb_distance);
  
  //add random object position setting code here
  //calculate position from object to the character goes here
 
  if (twoD_mode == 1){
  //draw the character in 2D
    ellipse(char_position_x, char_position_y, 10,10); 
    
    //draw the walls in 2D
    int i2 = 0;
    while (i2 < num_walls)
    {
      int j2 = 0;
      while (j2 < num_walls)
      {
        if (wall_array[i2][j2] == 1)
      {
        square(j2*wall_width, i2*wall_width,  wall_width);
      }
      
        j2 += 1;
      }
      i2 += 1;
    }
    }
    
    if (twoD_mode == 0){
      
      //define camera plane vector and direction vector, set field of view
      float FOV_mod = 0.66;
      float dvector_x = cos(char_theta);
      float dvector_y = sin(char_theta);
      float camplane_x = -FOV_mod*sin(char_theta);
      float camplane_y = FOV_mod*cos(char_theta);
       
      //draw the sky
      stroke(137, 179, 245);
      fill(137, 179, 245);
      square(0, -300, 600);
 
      
      //d
      stroke(50,125,50);
      fill(50,125,50);
      square(0, 300, 600);
 
      wall_array[orb_position_y][orb_position_x] = 2;
 
      
      for (int x = 0; x < screen_size_x; x++)
      {  
              float X_float = x;
              float camX = 2*X_float/screen_size_x - 1; //camera space X coordinate
              float RayDir_x = dvector_x + camplane_x*camX;
              float RayDir_y = dvector_y + camplane_y*camX;
              
              int map_x = floor(char_position_x/wall_width); //which cell is the player in the X direction?
              int map_y = floor(char_position_y/wall_width); //which cell is the player in the Y direction?
              
              float side_dist_x = 0; //distance to nearest X side
              float side_dist_y = 0; //distance to nearest Y side
              
              float delta_dist_x = 0;
              float delta_dist_y = 0;
              
              //calculate the stepping distance
              
              if (RayDir_x == 0)
              {
                delta_dist_x = 1e30;
              }
              else
              {
                delta_dist_x = abs(1/ RayDir_x);
              }
              
              if (RayDir_y == 0)
              {
                delta_dist_y = 1e30;
              }
              else
              {
                delta_dist_y = abs(1/ RayDir_y);
              }
                 
             
              float perp_wall_dist; //distance to the wall perpendicular to the camera plane
              
              //which direction to step in (+-1)
              int stepX = 1;
              int stepY = 1;
              
              int hit = 0; //wall hit check flag
              int side = 0; // which orientation wall, vertical or horizontal
              
              //calculate initial distance to side
              if (RayDir_x < 0)
              {
                stepX = -1;
                side_dist_x = (char_position_x - map_x*wall_width)*delta_dist_x;
              }
              else
              {
                stepX = 1;
                side_dist_x = ((map_x+1)*wall_width - char_position_x)*delta_dist_x;
              }
              if (RayDir_y < 0)
              {
                stepY = -1;
                side_dist_y = (char_position_y - map_y*wall_width)*delta_dist_y;
              }
              else
              {
                stepY = 1;
                side_dist_y = ((map_y+1)*wall_width - char_position_y)*delta_dist_y;
              }
              
              
              //DDA
              while(hit == 0)
              {
                
                //advance the ray
                if (side_dist_x < side_dist_y)
                {
                  side_dist_x += delta_dist_x*wall_width;
                  map_x += stepX;
                  side = 0;
                }
                else 
                {
                  side_dist_y += delta_dist_y*wall_width;
                  map_y += stepY;
                  side = 1;
                }
                if (wall_array[map_y][map_x] == 1)
                hit = 1;
                else if (wall_array[map_y][map_x] == 2 && orb_distance < 4)
                hit = 2;
              }
              
 
              
              //calculate perpendicular distance to the wall
              if (side == 0)
              {
                perp_wall_dist = (side_dist_x - delta_dist_x*wall_width);
              }
              else 
              {
                perp_wall_dist = (side_dist_y - delta_dist_y*wall_width);
              }
              
              
              perp_wall_dist = perp_wall_dist/(screen_size_x/2);
              
 
              
              int lineheight = floor(screen_size_y/(perp_wall_dist*10));
              int draw_start = -lineheight/2 + screen_size_y/2;
 
              if(draw_start < 0) 
                draw_start = 0;
 
              int draw_end = lineheight/2 + screen_size_y/2;
              
 
              if(draw_end > screen_size_y)
                draw_end = screen_size_y;
 
              if (side == 1 && hit == 1)
                {
                    stroke(150,150,150);     //stroke color for vertical walls
                }
              else if (side == 0 && hit == 1)
                {
                  stroke(55,55,55);      //stroke color for horizontal walls
                }
              else if (side == 1 && hit == 2)
                {
                 stroke(255,255,100);      //stroke color for horizontal walls
                }
              else if (side == 0 && hit == 2)
                {
                 stroke(127,127,50);      //stroke color for horizontal walls
                }
                
              line(x, draw_start, x, draw_end);
 
      }
 
    }
 
  key_press = 0;
}
