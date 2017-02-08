// modules: gtk+-3.0 poppler-glib
using Gtk;

public class PdfTag : Window {
	private string filename;
	private Button button;
	private Entry title_entry;
	private Entry author_entry;
	private Entry subject_entry;
	private Entry keywords_entry;
	private Entry create_entry;
	private Entry modify_entry;
	private HeaderBar header;
	private CheckButton check;
	private string overwrite = null;

	public PdfTag () {

		header = new HeaderBar ();
		header.title = "PdfTag";
		header.subtitle = "Add or modify metadata";
		header.set_show_close_button (true);

		this.set_titlebar (header);
		this.destroy.connect (Gtk.main_quit);
		this.set_default_size (350, 70);
		this.resizable = true;
		this.border_width = 10;
		this.window_position = Gtk.WindowPosition.CENTER;

		var open_button = new Button.from_icon_name ("document-open-symbolic", IconSize.SMALL_TOOLBAR);
		open_button.clicked.connect (on_open_clicked);
		header.add (open_button);

		var grid = new Grid ();

		title_entry = new Entry ();
		title_entry.set_text ("Title");
		title_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		title_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				title_entry.set_text ("");
			}
		});
		author_entry = new Entry ();
		author_entry.set_text ("Author");
		author_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		author_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				author_entry.set_text ("");
			}
		});
		subject_entry = new Entry ();
		subject_entry.set_text ("Subject");
		subject_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		subject_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				subject_entry.set_text ("");
			}
		});
		keywords_entry = new Entry ();
		keywords_entry.set_text ("Keywords");
		keywords_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		keywords_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				keywords_entry.set_text ("");
			}
		});

		create_entry = new Entry ();
		create_entry.set_text ("YYYY:MM:DD HH:MM:SS");
		create_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		create_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				create_entry.set_text ("");
			}
		});
		modify_entry = new Entry ();
		modify_entry.set_text ("YYYY:MM:DD HH:MM:SS");
		modify_entry.set_icon_from_icon_name (EntryIconPosition.SECONDARY, "edit-clear-symbolic");
		modify_entry.icon_press.connect ((pos, event) => {
			if (pos == Gtk.EntryIconPosition.SECONDARY) {
				modify_entry.set_text ("");
			}
		});
		button = new Gtk.Button.with_label ("Tag");
		button.clicked.connect (on_tag);

		var title_label = new Label ("<b>Title</b>");
		title_label.set_use_markup (true);
		grid.attach (title_label, 0, 0, 1, 1);
		grid.attach (title_entry, 1, 0, 2, 1);
		var author_label = new Label ("<b>Author</b>");
		author_label.set_use_markup (true);
		grid.attach (author_label, 0, 1, 1, 1);
		grid.attach (author_entry, 1, 1, 2, 1);
		var subject_label = new Label ("<b>Subject</b>");
		subject_label.set_use_markup (true);
		grid.attach (subject_label, 0, 2, 1, 1);
		grid.attach (subject_entry, 1, 2, 2, 1);
		var keywords_label = new Label ("<b>Keywords</b>");
		keywords_label.set_use_markup (true);
		grid.attach (keywords_label, 0, 3, 1, 1);
		grid.attach (keywords_entry, 1, 3, 2, 1);
		var create_label = new Label ("<b>Created</b>");
		create_label.set_use_markup (true);
		grid.attach (create_label, 0, 4, 1, 1);
		grid.attach (create_entry, 1, 4, 2, 1);
		var modify_label = new Label ("<b>Modified</b>");
		modify_label.set_use_markup (true);
		grid.attach (modify_label, 0, 5, 1, 1);
		grid.attach (modify_entry, 1, 5, 2, 1);
		grid.attach (button, 1, 6, 2, 1);

		check = new CheckButton.with_label ("Overwrite");
		grid.attach (check, 0, 6, 1, 1);

		grid.set_column_spacing (10);
		grid.set_row_spacing (10);
		grid.set_column_homogeneous (true);

		check.toggled.connect (on_toggled);

		this.add (grid);
	}

	private void on_open_clicked () {
		var file_chooser = new FileChooserDialog (
			"Open file", this, FileChooserAction.OPEN, "_Cancel", ResponseType.CANCEL, "_Open", ResponseType.ACCEPT);
		var filter = new FileFilter ();
		file_chooser.set_filter (filter);
		filter.add_mime_type ("image/pdf");
		if (file_chooser.run () == ResponseType.ACCEPT) {
			this.filename = file_chooser.get_filename ();
			this.header.title = Path.get_basename (filename);
			this.header.subtitle = filename.replace (Path.get_basename (filename), "");
		}
		file_chooser.destroy ();
		/* update text entries with current metadata */
		try {
			var date_format = "%Y:%m:%d %H:%M:%S";
			var document = new Poppler.Document.from_file ("file://" + filename, null);
			this.title_entry.text = document.title ?? "";
			this.author_entry.text = document.author ?? "";
			this.subject_entry.text = document.subject ?? "";
			this.keywords_entry.text = document.keywords ?? "";
			var creation_date = new DateTime.from_unix_local ((int64) document.creation_date);
			this.create_entry.text = creation_date.format (date_format);
			var mod_date = new DateTime.from_unix_local ((int64) document.mod_date);
			this.modify_entry.text = mod_date.format (date_format);
		} catch (Error e) {
			print ("%s\n", e.message);
		}
	}

	private void on_toggled () {
		if (this.check.active) {
			overwrite = "-overwrite_original";
			message ("Output will be overwritten");
		} else {
			overwrite = null;
			message ("Original file will be kept");
		}
	}

	private void on_tag () {
		try {
			string[] spawn_args = {"exiftool",
				@"-Title=$(this.title_entry.text)",
				@"-Author=$(this.author_entry.text)",
				@"-Subject=$(this.subject_entry.text)",
				@"-Keywords=$(this.keywords_entry.text)",
				@"-CreateDate=$(this.create_entry.text)",
				@"-ModifyDate=$(this.modify_entry.text)",
				filename, overwrite
			};
			string tmp_dir = Environment.get_tmp_dir ();
			string[] spawn_env = Environ.get ();
			string exif_stdout;
			string exif_stderr;
			int exif_status;
			Process.spawn_sync (tmp_dir, spawn_args, spawn_env, SpawnFlags.SEARCH_PATH, null, out exif_stdout, out exif_stderr, out exif_status);
		} catch (Error e) {
			stderr.printf ("%s\n", e.message);
			return;
		}
	}

	private static void remove_dir_recursively (string path) {
		string content;
		try {
			var directory = Dir.open (path);
			while ((content = directory.read_name ()) != null) {
				var content_path = path + Path.DIR_SEPARATOR_S + content;
				if (FileUtils.test (content_path + Path.DIR_SEPARATOR_S + content, FileTest.IS_DIR)) {
					remove_dir_recursively (content_path);
					FileUtils.remove (content_path);
				} else {
					FileUtils.remove (content_path);
				}
			}
			FileUtils.remove (path);
		} catch (FileError e) {
			error ("%s\n", e.message);
		}
	}

}

int main (string[] args) {
	Gtk.init (ref args);

	var header = new Gtk.HeaderBar ();
	header.set_show_close_button (true);

	var pdftag = new PdfTag ();

	pdftag.show_all ();

	Gtk.main ();
	return 0;
}
