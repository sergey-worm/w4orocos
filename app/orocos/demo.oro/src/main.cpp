#include "components.hpp"
#include "rtt/os/main.h"

int main( int argc, char** argv)
{
	printf("Hello Oro!\n\n");
	RTT::TaskContext* cntrl = new Controller("cntrl");
	RTT::TaskContext* servo = new Servo("servo");
	RTT::TaskContext* shaft = new Shaft("shaft");
	RTT::TaskContext* encdr = new Encoder("encdr");

	RTT::ConnPolicy policy = RTT::ConnPolicy::buffer(10);
	int ok = cntrl->ports()->getPort("tx-servo")->connectTo(servo->ports()->getPort("rx-cntrl"), policy);
	assert(ok);
	assert(cntrl->ports()->getPort("tx-servo")->connected());
	assert(servo->ports()->getPort("rx-cntrl")->connected());

	servo->addPeer(shaft);
	assert(servo->hasPeer(shaft->getName()) && !shaft->hasPeer(servo->getName()));

	encdr->addPeer(shaft);
	assert(encdr->hasPeer(shaft->getName()) && !shaft->hasPeer(encdr->getName()));

	encdr->addPeer(cntrl);
	assert(encdr->hasPeer(cntrl->getName()) && !cntrl->hasPeer(encdr->getName()));

	int prio = 0;
	cntrl->setActivity(new RTT::Activity(prio, 1.0));
	encdr->setActivity(new RTT::Activity(prio, 0.5));

	cntrl->configure();
	servo->configure();
	encdr->configure();
	shaft->configure();

	cntrl->start();
	servo->start();
	shaft->start();
	encdr->start();

	sleep(3);

	cntrl->stop();
	servo->stop();
	shaft->stop();
	encdr->stop();

	printf("Bye-bye!\n\n");
	return 0;
}

