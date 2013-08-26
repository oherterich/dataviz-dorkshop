String[] rawData; //String for the raw data from .csv file
String[][] boxOffice; //String to hold all data in rows and columns

void setup() {

  size(displayWidth, displayHeight); //uses resolution on monitor for the sketch size
  colorMode(HSB, 255);

  //First, we will import the .csv file into an array of strings.
  //Processing separates the data by line breaks. This means that
  //the info "Avatar 760.5 2009" will be one element of the array.
  rawData = loadStrings("boxOffice.csv");

  //In order to get a more manageable data set, we will split the
  //data up into a two-dimensional array of rows and columns.
  splitData();
}

void draw() {

  background(255);

  //Uncomment the following lines to draw different visualizations.
  //drawLines();
  //drawCircles();
  //drawCirclesHover();
  //drawBarChartGross();
  //drawLineGraph();
  //drawPieGraph();
}

void drawLines() {

  //We will loop through the data using a for loop. We're using rawData.length because
  //it has the same number of rows as our more refined data has.
  for (int i = 0; i < rawData.length; i++) {

    //Draw a line, with its length based on the number from our data.
    line(0, i*10+100, int(boxOffice[i][1]), i*10+100);
  }
}

void drawCircles() {

  //Loop through our rows of data
  for (int i = 0; i < rawData.length; i++) {

    //Draw an ellipse with its size based on our data.
    ellipse(width/2, height/2, int(boxOffice[i][1]), int(boxOffice[i][1]));
  }
}

void drawCirclesHover() {

  textAlign(CENTER);

  //This variable is used to determine the text of which position of the array should be displayed
  //It is set to -1 because if nothing is hovered, we don't want to see any text.
  int selected = -1; 

  //Loop through our rows of data
  for (int i = 0; i < rawData.length; i++) {
    fill(255);

    //To hover, we need to check to see if the distance between the mouse and the center of the circle
    //is LESS than the radius of the circle and GREATER than the radius of the circle that beside it.
    //This prevents multiple hovers - it only checks to see if we are hovering over the part of the circle
    //that we can see (not the parts that are overlapped).
    if (i < rawData.length-1) {
      if (dist(mouseX, mouseY, width/2, height/2) <= int(boxOffice[i][1])/2 && dist(mouseX, mouseY, width/2, height/2) >= int(boxOffice[i+1][1])/2) {
        fill(200);
        selected = i; //The text of the current hovered circle should be displayed
      }
    }

    //Draw an ellipse with its size based on our data.
    ellipse(width/2, height/2, int(boxOffice[i][1]), int(boxOffice[i][1]));
  }

  //We use this if statement because our array does not have an index of -1. Only display text if we have a real value here.
  if (selected != -1) {
    fill(0);
    textSize(16);
    text(boxOffice[selected][0], width/2, height/2-20);
    text("$" + boxOffice[selected][1] + " (million)", width/2, height/2);
    text(boxOffice[selected][2], width/2, height/2+20);
  }
}


void drawBarChartGross() {

  int barWidth = 30; //define a width for the bars of the chart

  //If we want to arrange the data by lowest gross to highest gross, we should
  //first loop through all of the data. Because we want the highest numbers furthest
  //to the right, we should start drawing the data from the right side of the screen
  //and move left. Each bar is drawn proportionally to the data. The positioning of 
  //the data is not particularly important - notice how we used the number in our
  //array to determine the height of each rectangle.
  for (int i=0; i<rawData.length; i++) {
    rect(width - i*barWidth - (width-barWidth*rawData.length)/2, height - int(boxOffice[i][1])/2 - 100, barWidth, int(boxOffice[i][1])/2);
  }
}

void drawLineGraph() {

  //We need a counter to move our points every time we draw. Like the bar chart,
  //we should start at the right and work left, going from high values to low values
  int counter = width-100;

  //This simple calculation makes my chart proportionate to the size of my screen
  int pointDist = int((width-100)/rawData.length);

  //First we will loop through all of the data
  for (int i=0; i<rawData.length; i++) {

    //We need to map the values of the data. Instead of being from 0 to 1000, as they
    //are now, we should change the range to be proportionate to our sketch.
    //This will be the y value of our points and lines.
    float point = map(float(boxOffice[i][1]), 0, 1000, height-50, 50);

    //We start at every point after 0, because we cannot draw a line from the first
    //element to anything before it - there is nothing before it!
    if (i>0) { 

      //Like the first point, let's map the values of the array. This time we are
      //changing the values of the part of the array that is directly previous to the
      //point we are working with. This is because lines must be draw from one point
      //to another, so we need to sets of values.
      float prevPoint = map(float(boxOffice[i-1][1]), 0, 1000, height-50, 50);

      //Draws the line from one point to the other using the counter and point values.
      strokeWeight(3);
      line(counter, prevPoint, counter-pointDist, point);

      //Draw a circle on each data point for emphasis.
      fill(255);
      ellipse(counter, prevPoint, 10, 10);

      //Let's create a variable that finds the distance between each point and the mouse.
      //We'll use this to detect hover later.
      float distPoint = dist(counter, prevPoint, mouseX, mouseY);

      if (distPoint < 10) {

        //Write the relevant data on the screen when you hover
        fill(0);
        textAlign(CENTER);
        text(boxOffice[i-1][0] + ": " + boxOffice[i-1][1] + " million dollars", width/2, height-50);

        //Draw a filled box when you hover
        fill(0);
        ellipse(counter, prevPoint, 10, 10);
      }

      //Iterate the counter. Remember we are drawing from right to left!
      counter-=pointDist;
    }
  }
}

void drawPieGraph() {
  //We need a variable that contains the sum of all of our data points
  //We use this in order to find out how much of the pie each piece will take.
  float totalGross = 0;

  //We will loop through only the first 6 of the data points. We don't want a pie chart with 30 pieces!
  //Add up all of the data points to find the total.
  for (int i = 0; i < 7; i++) {
    totalGross += int(boxOffice[i][1]);
  }

  //This variable will be used to offset the angle in order to draw each piece of the pie.
  float totalAngle = 0;

  //Loop through our six data points again.
  for (int i = 0; i < 7; i++) {

    //We need to do a little math to find the size of the wedge. 
    //Our current data point divided by the total gives us a percentage.
    //Multiply that by 360 to find the angle (a circle has 360 degrees)
    float angle = (int(boxOffice[i][1])/totalGross)*360;

    fill(i*20);
    stroke(255);
    //The pieces of the pie will be drawn one after the other, with each piece starting at the
    //angle in which the other piece ended. This will complete the circle.
    arc(width/2, height/2, 500, 500, radians(totalAngle), radians(totalAngle+angle));

    //Each time we need to increase the totalAngle by the number of degrees in the piece we just drew.
    //This will allow us to have consistent placement for the pieces.
    totalAngle+=angle;
  }
}

void splitData() {

  //The string that will hold our final data is initialized.
  //The number of rows is equal to the number of rows we had in
  //our initial data set. We have three columns of data: name,
  //box office gross, and year.
  boxOffice = new String[rawData.length][3];

  //Here we will loop through the raw data, row by row.
  //We need to split up the original data, for example
  //"Avatar 760.5 2009" into distinct columns
  for (int i=0; i<rawData.length; i++) {

    //The follow line of code uses a temporary array of strings
    //to separate data into columns. It separates the raw data by
    //a comma, which is how the .csv was imported. We will now
    //have a string array with three pieces of information each
    //time the loop is run: name, box office gross, and year.
    //This will happen for each row (movie).
    String[] pieces = split(rawData[i], ",");

    //Now I should loop through that array I just made. I will
    //set the information equal to its corresponding place in our
    //main data array: boxOffice. For example, Avatar is the first
    //movie in our data set. So, boxOffice[0][0] will be "Avatar,
    //boxOffice[0][1] will be "760.5", and boxOffice[0][2] will
    //be "2009"
    for (int j=0; j<pieces.length; j++) {
      boxOffice[i][j] = pieces[j];
    }
  }
}

//This function simply allows us to run full screen mode in Processing
boolean sketchFullScreen() {
  return true;
}

