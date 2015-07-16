#include "defs.h"

#include DEF_MPERS_TYPE(stack_t)

#include <signal.h>

#include MPERS_DEFS

#include "xlat/sigaltstack_flags.h"

static void
print_stack_t(struct tcb *tcp, unsigned long addr)
{
	stack_t ss;

	if (!addr) {
		tprints("NULL");
		return;
	}

	if (umove(tcp, addr, &ss) < 0) {
		tprintf("%#lx", addr);
		return;
	}

	tprintf("{ss_sp=%#lx, ss_flags=", (unsigned long) ss.ss_sp);
	printflags(sigaltstack_flags, ss.ss_flags, "SS_???");
	tprintf(", ss_size=%lu}", (unsigned long) ss.ss_size);
}

SYS_FUNC(sigaltstack)
{
	if (entering(tcp)) {
		print_stack_t(tcp, tcp->u_arg[0]);
	} else {
		tprints(", ");
		print_stack_t(tcp, tcp->u_arg[1]);
	}
	return 0;
}
