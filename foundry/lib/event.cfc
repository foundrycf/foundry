component name="event" extends="arrayobj" {
	property name="warned" type="boolean";
	property name="eventType" type="string";


	public event function init(name = "") {
		this['warned'] = false;

		this['eventType'] = arguments.name;

		super.init();
		return this;
	}
}