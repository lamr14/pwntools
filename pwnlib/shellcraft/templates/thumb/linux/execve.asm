<%
    from pwnlib.shellcraft import thumb
    from pwnlib.abi import linux_arm_syscall
%>
<%docstring>
Execute a different process.

    >>> path = '/bin/sh'
    >>> argv = ['sh', '-c', 'echo Hello, $NAME; exit $STATUS']
    >>> envp = {'NAME': 'zerocool', 'STATUS': 3}
    >>> sc = shellcraft.arm.linux.execve(path, argv, envp)
    >>> io = run_assembly(sc)
    >>> io.recvall()
    'Hello, zerocool\n'
    >>> io.poll(True)
    3
</%docstring>
<%page args="path = '/bin///sh', argv=[], envp={}"/>
<%
if isinstance(envp, dict):
    envp = ['%s=%s' % (k,v) for (k,v) in envp.items()]

regs = linux_arm_syscall.register_arguments
%>
% if argv:
    ${thumb.pushstr_array(regs[2], argv)}
% else:
    ${thumb.mov(regs[2], 0)}
% endif
% if envp:
    ${thumb.pushstr_array(regs[3], envp)}
% else:
    ${thumb.mov(regs[3], 0)}
% endif
    ${thumb.pushstr(path)}
    ${thumb.syscall('SYS_execve', 'sp', regs[2], regs[3])}
