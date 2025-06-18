import cv2
import os

def create_video_from_frames(images_folder, output_video, frame_rate):
    # Get all the frame filenames sorted numerically
    frame_files = sorted([f for f in os.listdir(images_folder) if f.startswith("frame") and f.endswith(".png")], 
                         key=lambda x: int(x.replace("frame", "").replace(".png", "")))

    if not frame_files:
        print("No frames found in the folder.")
        return

    # Read the first frame to determine video dimensions
    first_frame_path = os.path.join(images_folder, frame_files[0])
    first_frame = cv2.imread(first_frame_path)
    height, width, _ = first_frame.shape

    # Initialize video writer
    fourcc = cv2.VideoWriter_fourcc(*"mp4v")  # codec for mp4
    video_writer = cv2.VideoWriter(output_video, fourcc, frame_rate, (width, height))

    # Write each frame to the video
    for frame_file in frame_files:
        frame_path = os.path.join(images_folder, frame_file)
        frame = cv2.imread(frame_path)
        video_writer.write(frame)

    # Release the video writer
    video_writer.release()
    print(f"Video saved as {output_video}")

# Parameters
images_folder = "images"
output_video = "output_video.mp4"
frame_rate = 60  # Frames per second

create_video_from_frames(images_folder, output_video, frame_rate)
