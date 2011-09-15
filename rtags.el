(defun rtags-load-file () (interactive)
  (start-process "rtags-load" nil "rtags" "--timeout=1000" "--autostart" "--command=load" (buffer-file-name)))

(defun rtags-goto-symbol-at-point()
  (interactive)
  (save-excursion
    (let ((bufname (buffer-name))
          (line (int-to-string (line-number-at-pos)))
          (column nil))
      (if (looking-at "[0-9A-Za-z_]")
          (progn
            ;; (message (concat (int-to-string (point)) " 1 " (int-to-string (- (point) (point-at-bol) -1))))
            (while (and (> (point) 0) (looking-at "[0-9A-Za-z_]"))
              (backward-char))
            ;; (message (concat (int-to-string (point)) " 2 " (int-to-string (- (point) (point-at-bol) -1))))
            (if (not (looking-at "[0-9A-Za-z_]"))
                (forward-char))
            ;; (message (concat (int-to-string (point)) " 3 " (int-to-string (- (point) (point-at-bol) -1))))
            (setq column (int-to-string (- (point) (point-at-bol) -1)))

            ;; /foo/bar:12:13
            (with-temp-buffer
              (call-process (executable-find "rtags") nil t nil "--timeout=50" "--command=followsymbol"
                            bufname (concat "--line=" line) (concat "--column=" column))
              (if (string-match "\\(.*\\):\\([0-9]+\\):\\([0-9]+\\)" (buffer-string))
                  (progn
                    (setq line (string-to-int (match-string 2 (buffer-string))))
                    (setq column (string-to-int (match-string 3 (buffer-string))))
                    (find-file (match-string 1 (buffer-string)))
                    (goto-char (point-min))
                    (forward-line (- line 1))
                    (forward-char column)))))))))

