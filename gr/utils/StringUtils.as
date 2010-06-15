package gr.utils
{
	public class StringUtils
	{
        public static function numberFormat( _num:Number, _decimalPlace:uint = 0 ):String {
			var neg:Boolean = (_num < 0);
			var num:Number = Math.abs(_num);
			var roundedAmount:String = String(num.toFixed(_decimalPlace));

            //split string into array for dollars and cents
			var parts:Array = roundedAmount.split(".");
			var wholePart:String = String(parts[0]);
			var fractionalPart:String = String(parts[1]);
			
			//create dollar amount
			var wholeStrFinal:String = ""
			var i:int = 0
			for (i; i < wholePart.length; i++) {
				if (i > 0 && (i % 3 == 0 )) {
					wholeStrFinal = "," + wholeStrFinal;
				}
				
				wholeStrFinal = wholePart.substr( -i -1, 1) + wholeStrFinal;
			}	

			var fractionalStrFinal:String = fractionalPart;
			var missingZeros:int = _decimalPlace - fractionalStrFinal.length;
			if (fractionalStrFinal.length < _decimalPlace) {
				for (var j:int = 0; j < missingZeros; j++)  {
					fractionalStrFinal += "0";
				}
			}

			var finalString:String = wholeStrFinal;
			if (neg) {
				finalString = "-" + wholeStrFinal;
			}

			if(_decimalPlace > 0) {
				finalString += "." + fractionalStrFinal;
			} 
			
			return finalString;
        }
        
		public static function currency( _num:Number, _decimalPlace:uint = 2, _currency:String="$" ):String {
			return _currency + numberFormat( _num, _decimalPlace );
		}
		
		public static function tr( _str:String, _tr:Object ):String {
			var result:String = _str;
			for( var search:String in _tr ) {
				var repl:String = _tr[search];
				result = result.replace( new RegExp(search, "gi"), repl );
			}
			
			return result;
		}

		public static function secondsToString( _time:int ):String {
			var result:String = "";

			var days:int = (int)(_time/86400);
			if( days > 0 ) {
				result += days + " " + ((days == 1) ? "day" : "days");
			}

			var hours:int = (int)((_time/3600) - (days * 24));
			if( hours > 0 ) {
				if( days > 0 ) { result += " "; }
				result += hours + " " + ((hours == 1) ? "hr" : "hrs");
			}
			
			if( days <= 0 ) {
				var minutes:int = (int)((_time / 60) - (days * 1440) - (hours * 60));
				if( minutes > 0 ) {
					if( hours > 0 ) { result += " "; }
					result += minutes + " " + ((minutes == 1) ? "min" : "mins");
				} else if (days == 0 && hours == 0) {
					result += "< 1 min";
				}
			}

			return result;
		}

		public static const PAD_RIGHT:String = "right";
		public static const PAD_LEFT:String = "left";
		public static function pad(_str:String, _width:int, _pad:String = " ", _padSide:String = "left" ):String
		{
			var padding:String = "";
			for (var i:uint = 0; i < (_width - _str.length); ++i) {
				padding += _pad;
			}

			if( _padSide == PAD_LEFT ) {
				return padding + _str;
			} else if( _padSide == PAD_RIGHT ) {
				return _str + padding;
			} else {
				throw new Error("Unknown pad side given: " + _padSide);
				return padding + _str;
			}
		}

		public static function secondsToCountdownString( _secs:int, _forceIncludeDays:Boolean = false ):String {
			if( _secs <= 0 ) {
				if( _forceIncludeDays ) {
					return "0 Days 00:00:00";
				} else {
					return "00:00:00";
				}
			}

			var parts:Array = [];

			var days:int = (int)(_secs/86400);
			var daysStr:String = "";
			if( _forceIncludeDays || days > 0 ) {
				 daysStr = String(days) + ((days == 1) ? ' Day ' : ' Days ');
			}

			var hours:int = (int)((_secs/3600) - (days * 24));
			parts.push( StringUtils.pad(String(hours), 2, "0") );
			
			var minutes:int = (int)((_secs / 60) - (days * 1440) - (hours * 60));
			parts.push( StringUtils.pad(String(minutes), 2, "0") );

            var seconds:int = _secs % 60
			parts.push( StringUtils.pad(String(seconds), 2, "0") );

			return daysStr + parts.join(':');
		}
	}
}
