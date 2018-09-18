#ifndef MY_COMPONENT_HPP
#define MY_COMPONENT_HPP

#include <rtt/RTT.hpp>

class Controller : public RTT::TaskContext
{
	double _value;
	RTT::OutputPort<double> _servo_tx_port;
public:
	Controller(std::string const& name);
	bool configureHook();
	bool startHook();
	void updateHook();
	void errorHook();
	void stopHook();
	void cleanupHook();
	void positionChanged(double v);
};

class Servo : public RTT::TaskContext
{
	RTT::OperationCaller<void(double)> _setShaftPosOp;
	RTT::InputPort<double>  _cntrl_rx_port;
public:
	Servo(std::string const& name);
	bool configureHook();
	bool startHook();
	void updateHook();
	void errorHook();
	void stopHook();
	void cleanupHook();
};

class Encoder : public RTT::TaskContext
{
	double _value;
	RTT::OperationCaller<double(void)> _getShaftPosOp;
	RTT::internal::Signal<void(double)> _positionChangedSignal;
public:
	Encoder(std::string const& name);
	bool configureHook();
	bool startHook();
	void updateHook();
	void errorHook();
	void stopHook();
	void cleanupHook();
};

class Shaft : public RTT::TaskContext
{
	double _value;
public:
	Shaft(std::string const& name);
	bool configureHook();
	bool startHook();
	void updateHook();
	void errorHook();
	void stopHook();
	void cleanupHook();
	double getPosition();
	void   setPosition(double v);
};

#endif // MY_COMPONENT_HPP
