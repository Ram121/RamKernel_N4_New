--- init.rc	2017-05-10 00:12:04.818994196 +0530
+++ init.rc.edited	2017-05-10 00:21:40.570752816 +0530
@@ -1869,3 +1869,8 @@
 on property:service.vpnclientd.enable=0
     stop vpnclientd

+# start init.d support
+service initd-support /sbin/initd-support.sh
+	class main
+	user root
+	oneshot
