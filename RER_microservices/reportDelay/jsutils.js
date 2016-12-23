var imports = new JavaImporter( java.lang.System, java.lang.Long );

function millsToDate( request ){ 
  with( imports ){
    var date = new Date( request.$ );
    return date.toString(); // "Dec 20"
  } 
}

function getMillsToTime( request ){ 
  with( imports ){
    var date = new Date( request.$ );
    minutes = date.getMinutes();
    if ( minutes < 10 ){
      minutes = "0" + minutes;
    }
    var time = date.getHours() + ":" + minutes
    return time;
  }
}

function getRandomMillsToTime( request ){ 
  with( imports ){
    var randomEta = request.$ + Math.round( Math.random()*600000 );
    r = { "$": randomEta }
    return getMillsToTime( r );
  }
}

function getStartDayMills( request ){
  with( imports ){
    var start = new Date();
    start.setHours("0");
    start.setMinutes("0");
    start.setSeconds("0");
    return Long.parseLong( start.getTime() );
  }
}

function getEndDayMills( request ){
  with( imports ){
    var end = new Date();
    end.setHours("23");
    end.setMinutes("59");
    end.setSeconds("59");
    return Long.parseLong( end.getTime() );
  }
}


function timeToMills( request ){
  with( imports ){
    var time = request.$;
    var timeSplit = time.split( ":" );
    var date = new Date();
    var refDate = new Date(
      date.getFullYear(),
      date.getMonth(),
      date.getDate(),
      timeSplit[ 0 ],
      timeSplit[ 1 ],
      0, 0 );
    return Long.parseLong( refDate.getTime() );
  } 
}