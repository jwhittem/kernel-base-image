
build-kvm:
	./build.sh

clean:
	rm -rf output/

move:
	mv output/* $(HOME)/vms/
