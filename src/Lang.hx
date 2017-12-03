import mt.data.GetText;

class Lang {
	public static function init(id:String) {
	}

	public static inline function untranslated(str:Dynamic) : LocaleString {
		return cast Std.string(str);
	}
}