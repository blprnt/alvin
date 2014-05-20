class Pilot implements Comparable {
  String name;
  int dives;
  float hours;
  
  int compareTo(Object p2) {
    return(int(hours - ((Pilot) p2).hours));
  }    
}

