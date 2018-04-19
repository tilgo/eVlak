public with sharing class TestClass {

	public abstract class myWrapper {
		public Integer code {get; set;}
		public String msg {get; set;}

		public String concatenate(Integer code, String msg) {
			return String.valueOf(code) + ' ' + msg;
		}

		public abstract void setCode();
		
	}

	public class myWrapper2 extends myWrapper {
		public String id {get; set;}
		public String name {get; set;}

		public  overrride void setCode() {
			this.code = this.code*5;
		}

		//public myWrapper2(String id, String name) {
		//	this.id = id;
		//	this.name = name;
		//}
	}

	public class newWrapper {
		public String id {get; set;}
		public String name {get; set;}
	}

	public void tstMethod() {
		//myWrapper2 mw2 = new myWrapper2('test', 'testName');
		myWrapper2 mw2 = new myWrapper2();
		mw2.id = 'test';
		mw2.name = 'testName';
		//mw2.code = 15;
		mw2.msg = 'testMsg';

		System.debug(mw2);
		System.debug(mw2.id);
		System.debug(mw2.name);
		System.debug(mw2.code);
		System.debug(mw2.msg);
		System.debug(mw2.concatenate(mw2.code, mw2.msg));
		mw2.setCode();
		System.debug(mw2.code);
		System.debug(mw2.concatenate(mw2.code, mw2.msg));
	}
	

	public void tstMethod2() {
		newWrapper nw = new newWrapper();
		nw.name = 'test';
		nw.id = 'testId';

		System.debug(nw);
	}


	
}