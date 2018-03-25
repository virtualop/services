deploy do |machine|
    machine.install_service(service: "libvirt.libvirt")
    machine.ssh("virsh net-start default")

    machine.install_service(service: "isoremix.isoremix")
    machine.fetch_ubuntu_iso(version: "17.10")
    machine.rebuild_debian_iso(source_iso: "ubuntu-17.10.1-server-amd64.iso")

    iptables_script = machine.generate_iptables_script
    #machine.ssh(iptables_script)
    iptables_script
end
