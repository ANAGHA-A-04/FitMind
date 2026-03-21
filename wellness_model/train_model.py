from sklearn.ensemble import RandomForestClassifier
import joblib

from fitmind_chatbot.train_model import model
from preprocess import load_and_preprocess

#load data
df = load_and_preprocess()

#features and labels
x = df[['steps','sleep','stress','mood']]
y = df[['label']]

#train model
model =RandomForestClassifier(n_estimators=100)
model.fit(x,y)

#save the model
joblib.dump(model,'model/mental_wellness_model.pkl')

print("Model trained and saved successfully!")