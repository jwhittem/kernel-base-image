
build-kvm:
	packer init -upgrade base-kvm.pkr.hcl
	packer build base-kvm.pkr.hcl	 

clean:
	rm -rf output/

move:
	mv output/* $(HOME)/vms/
