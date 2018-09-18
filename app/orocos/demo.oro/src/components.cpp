#include "components.hpp"
#include <rtt/Component.hpp>

//--------------------------------------------------------------------------------------------------
// CONTROLLER
//--------------------------------------------------------------------------------------------------

Controller::Controller(std::string const& name) : TaskContext(name)
{
	printf("cntrl:  construct.\n");
	this->ports()->addPort("tx-servo", _servo_tx_port).doc("Command tx port.");
	_value = 0.0;
}

bool Controller::configureHook()
{
	printf("cntrl:  configure.\n");
	if (!_servo_tx_port.connected())
	{
		printf("cntrl:  ERR:  configureHook:  'tx-servo' is not connected.\n");
		return false;
	}
	return true;
}

bool Controller::startHook()
{
	printf("cntrl:  start.\n");
	return true;
}

void Controller::updateHook()
{
	assert(_servo_tx_port.connected());
	_value += 0.1;
	printf("\n");
	printf("cntrl:  updateHook:  wr:  val=%f.\n", _value);
	_servo_tx_port.write(_value);
}

void Controller::errorHook()
{
	printf("cntrl:  run-time error.\n");
}

void Controller::stopHook()
{
	printf("cntrl:  stop.\n");
}

void Controller::cleanupHook()
{
	printf("cntrl:  cleaning up.\n");
}

// signal handler
void Controller::positionChanged(double v)
{
	printf("cntrl:  posChanged:  new: val=%f.\n", v);
	if (v != _value)
		printf("cntrl:  ERR:  posChanged:  read=%f, but expected=%f.\n", v, _value);
}

//--------------------------------------------------------------------------------------------------
// SERVO
//--------------------------------------------------------------------------------------------------

Servo::Servo(std::string const& name) : TaskContext(name)
{
	printf("servo:  construct.\n");
	this->ports()->addEventPort("rx-cntrl", _cntrl_rx_port).doc("Command rx port.");
}

bool Servo::configureHook()
{
	printf("servo:  configure.\n");
	if (!_cntrl_rx_port.connected())
	{
		printf("cntrl:  ERR:  configureHook:  'rx-cntrl' is not connected.\n");
		return false;
	}
	TaskContext* peer = this->getPeer("shaft");
	if (!peer)
	{
		printf("encdr:  ERR:  configureHook:  no peer 'shaft'.\n");
		return false;
	}
	_setShaftPosOp = peer->getOperation("setPosition");
	if (!_setShaftPosOp.ready())
	{
		printf("encdr:  ERR:  configureHook:  oper 'setShaftPosOp' is not ready.\n");
		return false;
	}
	return true;
}

bool Servo::startHook()
{
	printf("servo:  start.\n");
	return true;
}

void Servo::updateHook()
{
	assert(_cntrl_rx_port.connected());
	double v;
	if (_cntrl_rx_port.read(v) == RTT::NewData)
	{
		printf("servo:  updateHook:  rd:  val=%f.\n", v);
		_setShaftPosOp(v);
	}
	else
	{
		//printf("servo:  ERR:  updateHook:  rd:  no data.\n");
	}
}

void Servo::errorHook()
{
	printf("servo:  run-time error.\n");
}

void Servo::stopHook()
{
	printf("servo:  stop.\n");
}

void Servo::cleanupHook()
{
	printf("servo:  cleaning up.\n");
}

//--------------------------------------------------------------------------------------------------
// ENCODER
//--------------------------------------------------------------------------------------------------

Encoder::Encoder(std::string const& name) : TaskContext(name)
{
	printf("encdr:  construct.\n");
}

bool Encoder::configureHook()
{
	printf("encdr:  configure.\n");
	TaskContext* peer = this->getPeer("shaft");
	if (!peer)
	{
		printf("encdr:  ERR:  configureHook:  no peer 'shaft'.\n");
		return false;
	}
	_getShaftPosOp = peer->getOperation("getPosition");
	if (!_getShaftPosOp.ready())
	{
		printf("encdr:  ERR:  configureHook:  oper 'getShaftPosOp' is not ready.\n");
		return false;
	}
	peer = this->getPeer("cntrl");
	RTT::Handle handle = _positionChangedSignal.connect(boost::bind(
	                         boost::mem_fn(&Controller::positionChanged), (Controller*)peer, _1));
	if (!handle.connected())
	{
		printf("encdr:  ERR:  configureHook:  signal 'posChanged' is not connected.\n");
		return false;
	}
	return true;
}

bool Encoder::startHook()
{
	printf("encdr:  start.\n");
	return true;
}

void Encoder::updateHook()
{
	double v = _getShaftPosOp();
	printf("encdr:  updateHook:  get: val=%f (%s).\n", v, v==_value?"old":"new");
	if (v != _value)
	{
		_value = v;
		_positionChangedSignal(v);
	}
}

void Encoder::errorHook()
{
	printf("encdr:  run-time error.\n");
}

void Encoder::stopHook()
{
	printf("encdr:  stop.\n");
}

void Encoder::cleanupHook()
{
	printf("encdr:  cleaning up.\n");
}

//--------------------------------------------------------------------------------------------------
// SHAFT
//--------------------------------------------------------------------------------------------------

Shaft::Shaft(std::string const& name) : TaskContext(name)
{
	printf("shaft:  construct.\n");
	this->addOperation("setPosition", &Shaft::setPosition, this, RTT::ClientThread).doc("Set pos.");
	this->addOperation("getPosition", &Shaft::getPosition, this, RTT::ClientThread).doc("Get pos.");
}

bool Shaft::configureHook()
{
	printf("shaft:  configure.\n");
	return true;
}

bool Shaft::startHook()
{
	printf("shaft:  start.\n");
	return true;
}

void Shaft::updateHook()
{
	printf("shaft:  updateHook.\n");
}

void Shaft::errorHook()
{
	printf("shaft:  run-time error.\n");
}

void Shaft::stopHook()
{
	printf("shaft:  stop.\n");
}

void Shaft::cleanupHook()
{
	printf("shaft:  cleaning up.\n");
}

void Shaft::setPosition(double v)
{
	printf("shaft:  setPosition: set: val=%f.\n", v);
	_value = v;
}

double Shaft::getPosition()
{
	//printf("shaft:  getPosition: get: val=%f.\n", _value);
	return _value;
}


ORO_CREATE_COMPONENT_TYPE()
ORO_LIST_COMPONENT_TYPE(Controller)
ORO_LIST_COMPONENT_TYPE(Servo)
ORO_LIST_COMPONENT_TYPE(Shaft)
ORO_LIST_COMPONENT_TYPE(Encoder)

