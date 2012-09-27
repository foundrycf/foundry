component name="event" extends="arrayobj" {
	property name="warned" type="boolean";

	public event function init() {
		this.warned = false;
		super.init();
		return this;
	}
}