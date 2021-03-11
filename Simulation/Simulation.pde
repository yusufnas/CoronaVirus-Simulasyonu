
    Ball[] balls;
    int[][] history;
    int frames, w = 900, h = 480;
    int circleSize = 60,
            circleX = (w / 10 - 10),
            circleY = (h / 3);
    boolean isStart = false, isBtnBaslat;
    int iPerson = 3, people = 100, minus = 160, plus = 200, temp;
    static int mult = 1, rtimer;

    @Override
    public void settings() {
        size(w, h);
    }

    @Override
    public void setup() {
        balls = new Ball[people];
        int count = 0;
        frames = 0;
        while (count < balls.length) {
            Ball b = new Ball(random(width / 3 + 5, width - 5), random(5, height - 5), 5); //random pos

            boolean ok = true;
            for (int i = 0; i < count; i++) {
                Ball c = balls[i];
                float d = PVector.dist(b.position, c.position);
                if (d <= b.radius + c.radius) {
                    ok = false;
                    break;
                }
            }

            if (ok) {
                balls[count] = b;
                count++;
            }
        }

        for (int i = 0; i < iPerson; i++) {
            int idx = floor(random(balls.length));
            Ball b = balls[idx];
            b.state = 1;
        }

        history = new int[3600][3];
    }

    @Override
    public void draw() {
        background(51);
        noStroke();

        int susceptible = 0;
        int infected = 0;
        int recovered = 0;

        for (Ball b : balls) {
            switch (b.state) {
                case 0:
                    susceptible++;
                    break;
                case 1:
                    infected++;
                    break;
                default:
                    recovered++;
                    break;
            }
        }

        history[frames][0] = susceptible;
        history[frames][1] = infected;
        history[frames][2] = recovered;

        for (int j = 0; j <= frames; j++) {
            int s = (int) (history[j][0] / 200.0 * 60);
            int i = (int) (history[j][1] / 200.0 * 60);
            int r = (int) (history[j][2] / 200.0 * 60);

            fill(102);
            rect(0, 0, width / 3, height);

            fill(0, 255, 0);
            rect(5, (h - 5) - (s * 3), 80, (h - 5) - (s * 3), 10);

            fill(255, 0, 0);
            rect(100, (h - 5) - (i * 3), 90, (h - 5) - (i * 3), 10);

            fill(0, 0, 255);
            rect(200, (h - 5) - (r * 3), 90, (h - 5) - (r * 3), 10);

        }

        fill(255);
        textSize(12);
        text("Sağlıklı: " + susceptible, 10, h / 2);
//        fill(255, 0, 0);
        text("Enfekte: " + infected, 110, h / 2);
//        fill(0, 0, 255);
        text("İyileşen: " + recovered, 210, h / 2);

        for (Ball b : balls) {
            Goster(b);
        }

        if (isStart) {
            for (int n = 0; n < 100; n++) {
                for (Ball b : balls) {
                    b.update();
                    b.checkBoundaryCollision();
                }

                for (int i = 0; i < balls.length; i++) {
                    for (int j = i + 1; j < balls.length; j++) {
                        balls[i].checkCollision(balls[j]);
                    }
                }
            }
            frames++;
        }

        fill(180);
        textSize(15);

        ellipse(circleX, circleY, circleSize * 2, circleSize);  //Baslat
        fill(80);
        if (!(isStart)) {
            text("BAŞLAT", circleX - 27, circleY + 5);
        } else {
            text("DURDUR", circleX - 30, circleY + 5);
        }

        fill(180);
        ellipse(circleX * 2.5f, circleY, circleSize * 2, circleSize);   //Yeniden baslat

        fill(80);
        text("YENİDEN\n BAŞLAT", circleX * 2.5f - 30, circleY - 5);
        HoverUpdate();

        TextUI();
    }

    void Goster(Ball b) {
        noStroke();
        if (b.state == 0) {
            fill(0, 255, 0);
        } else if (b.state == 1) {
            fill(255, 0, 0);
        } else {
            fill(0, 0, 255);
        }
        ellipse(b.position.x, b.position.y, b.radius * 2, b.radius * 2);
    }

    @Override
    public void mousePressed() {
        if (isBtnBaslat && isStart) {
            isStart = false;
            System.out.println(isStart);
            return;
        }
        if (isBtnBaslat) {
            isStart = true;
            System.out.println(isStart);
        }
        if (overPlus()) {
            switch (temp) {
                case 1:
                    people += Increment();
                    break;
                case 2:
                    mult += Increment();
                    break;
                default:
                    iPerson += Increment();
                    break;
            }
        }
        if (overMinus()) {
            switch (temp) {
                case 1:
                    people -= Increment();
                    if (people < 0) {
                        people = 0;
                    }
                case 2:
                    mult -= Increment();
                    if (mult < 1) {
                        mult = 1;
                    }
                    break;
                default:
                    iPerson -= Increment();
                    if (iPerson < 0) {
                        iPerson = 0;
                    }
                    break;
            }
        }

    }

    private void HoverUpdate() {
        if (overStart(circleX, circleY, circleSize)) {
            isBtnBaslat = true;
            if (isStart) {
                fill(0);
                text("DURDUR", circleX - 30, circleY + 5);
            } else {
                fill(0);
                text("BAŞLAT", circleX - 27, circleY + 5);
            }
        } else if (overRestart((int) (circleX * 2.5f), circleY, circleSize * 2) && mousePressed) {
            isStart = true;
            Restart();
        } else {
            isBtnBaslat = false;
        }
    }

    private boolean overStart(int x, int y, int size) {
        float disX = x - mouseX;
        float disY = y - mouseY;
        if (sqrt(sq(disX) + sq(disY)) < size / 2) {
            return true;
        } else {
            return false;
        }
    }

    private boolean overRestart(int x, int y, int size) {
        float disX = x - mouseX;
        float disY = y - mouseY;
        if (sqrt(sq(disX) + sq(disY)) < size / 2) {
            fill(0);
            text("YENİDEN\n BAŞLAT", circleX * 2.5f - 30, circleY - 5);
            return true;
        } else {
            return false;
        }
    }

    private void Restart() {
        for (int i = 0; i < balls.length; i++) {
            balls = new Ball[0];
        }
        setup();
    }

    private void TextUI() {
        stroke(0);
        fill(10);
        rect(minus, 8, 20, 13);
        rect(plus, 8, 20, 13);

        rect(minus, 38, 20, 13);
        rect(plus, 38, 20, 13);

        rect(minus, 68, 20, 13);
        rect(plus, 68, 20, 13);

        fill(200);
        text("Popülasyon: " + people, 20, 20);
        text("Mobilite hızı: " + mult, 20, 50);
        text("Hasta Sayısı : " + iPerson, 20, 80);
        text("İyileşme Süresi : " + rtimer / 35, 60, 110);

//        fill(0);
        text("-", minus + 5, 20);
        text("+", plus + 5, 20);
        text("-", minus + 5, 50);
        text("+", plus + 5, 50);
        text("-", minus + 5, 80);
        text("+", plus + 5, 80);

    }

    private boolean overPlus() {
        float disX = plus - mouseX;
        float disY = 8 - mouseY;
        if (sqrt(sq(disX) + sq(disY)) < 20) {
            rect(plus, 8, 20, 13);
            temp = 1;
            return true;
        } else if (sqrt(sq(disX) + sq(disY + 30)) < 20) {
            rect(plus, 38, 20, 13);
            temp = 2;
            return true;
        } else if (sqrt(sq(disX) + sq(disY + 60)) < 20) {
            rect(plus, 68, 20, 13);
            temp = 3;
            return true;
        } else {
            return false;
        }
    }

    private boolean overMinus() {
        float disX = minus - mouseX;
        float disY = 8 - mouseY;
        if (sqrt(sq(disX) + sq(disY)) < 20) {
            rect(minus, 8, 20, 13);
            temp = 1;
            return true;
        } else if (sqrt(sq(disX) + sq(disY + 30)) < 20) {
            rect(minus, 38, 20, 13);
            temp = 2;
            return true;
        } else if (sqrt(sq(disX) + sq(disY + 60)) < 20) {
            rect(minus, 68, 20, 13);
            temp = 3;
            return true;
        } else {
            return false;
        }
    }

    private int Increment() {
        return 1;
    }
