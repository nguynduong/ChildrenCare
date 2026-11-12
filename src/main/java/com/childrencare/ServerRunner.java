package com.childrencare;

import java.awt.Desktop;
import java.io.File;
import java.net.URI;
import org.apache.catalina.Context;
import org.apache.catalina.startup.Tomcat;

/**
 * Trình chạy nhúng máy chủ Tomcat trực tiếp bên trong IDE.
 * Bạn chỉ cần bấm "Run" class này để khởi động website và tự động mở trình duyệt Brave.
 */
public class ServerRunner {

    public static void main(String[] args) throws Exception {
        int port = 8080;
        String webappDir = new File("src/main/webapp").getAbsolutePath();

        Tomcat tomcat = new Tomcat();
        tomcat.setPort(port);
        tomcat.getConnector(); // Khởi tạo HTTP Connector mặc định

        // Đăng ký ứng dụng Web tại root path "/"
        Context context = tomcat.addWebapp("", webappDir);

        // Nạp các class đã biên dịch vào context
        File additionWebInfClasses = new File("target/classes");
        if (additionWebInfClasses.exists()) {
            org.apache.catalina.WebResourceRoot resources = new org.apache.catalina.webresources.StandardRoot(context);
            resources.addPreResources(new org.apache.catalina.webresources.DirResourceSet(
                    resources, "/WEB-INF/classes", additionWebInfClasses.getAbsolutePath(), "/"
            ));
            context.setResources(resources);
        }

        System.out.println("==================================================================");
        System.out.println("  CHILDREN CARE SYSTEM ĐANG KHỞI CHẠY...");
        System.out.println("  Địa chỉ: http://localhost:" + port);
        System.out.println("==================================================================");

        tomcat.start();

        // Tự động mở trình duyệt Brave (hoặc trình duyệt mặc định)
        openBraveBrowser("http://localhost:" + port);

        // Giữ tiến trình chạy cho tới khi tắt
        tomcat.getServer().await();
    }

    private static void openBraveBrowser(String url) {
        new Thread(() -> {
            try {
                Thread.sleep(1500); // Chờ 1.5s để server khởi động hoàn tất
                String userHome = System.getProperty("user.home");
                File braveLocal = new File(userHome, "AppData/Local/BraveSoftware/Brave-Browser/Application/brave.exe");
                File braveProgramFiles = new File("C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe");

                if (braveLocal.exists()) {
                    new ProcessBuilder(braveLocal.getAbsolutePath(), url).start();
                } else if (braveProgramFiles.exists()) {
                    new ProcessBuilder(braveProgramFiles.getAbsolutePath(), url).start();
                } else if (Desktop.isDesktopSupported() && Desktop.getDesktop().isSupported(Desktop.Action.BROWSE)) {
                    Desktop.getDesktop().browse(new URI(url));
                }
            } catch (Exception e) {
                System.out.println("Vui lòng mở trình duyệt và truy cập: " + url);
            }
        }).start();
    }
}

