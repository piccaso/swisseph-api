package main

import (
	"bytes"
	"fmt"
	"net/http"
	"net/url"
	"os/exec"
	"io"
)

func main() {
	http.Handle("/", http.FileServer(http.Dir("./static")))
	http.HandleFunc("/api", handler)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(err)
	}
}

func handler(w http.ResponseWriter, r *http.Request) {
	q, err := getParameter(r.URL, "q")
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	cmd := exec.Command("/bin/bash", "-c", "/bin/swetest " + q)
	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &out
	err = cmd.Run()
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.Header().Set("Content-Type", "text/plain")
	w.Write(out.Bytes())
	//io.WriteString(w, toUtf8(out.Bytes()))
}

func getParameter(u *url.URL, name string) (string, error) {
	values, ok := u.Query()[name]
	if !ok || len(values[0]) < 1 {
		return "", fmt.Errorf("Parameter '%v' not found", name)
	}
	return values[0], nil
}

func getOptionalParameter(u *url.URL, name string, defaultValue string) string {
	values, ok := u.Query()[name]
	if !ok || len(values[0]) < 1 {
		return defaultValue
	}
	return values[0]
}

func toUtf8(iso8859_1_buf []byte) string {
	var buf = bytes.NewBuffer(make([]byte, len(iso8859_1_buf)*4))
	for _, b := range(iso8859_1_buf) {
	   r := rune(b)
	   buf.WriteRune(r)
	}
	var o = bytes.Trim(buf.Bytes(), "\x00")
	return string(o)
 }