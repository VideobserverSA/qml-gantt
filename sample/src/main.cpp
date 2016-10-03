/****************************************************************************
**
** Copyright (C) 2015-2016 Dinu SV.
** (contact: mail@dinusv.com)
** This file is part of QML Gantt library.
**
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
****************************************************************************/

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "qrangeview.h"
#include "qganttmodel.h"
#include "qganttmodelitem.h"
#include "qganttmodellist.h"
#include "qganttdata.h"

#include "mytestclass.h"

Q_DECLARE_METATYPE(QGanttData*);
Q_DECLARE_METATYPE(MyTestClass*);

static int CONFIGURATION_MODEL_SIZE = 1500;
//static int CONFIGURATION_MODEL_SIZE = 20000;

int randBetween(int min, int max){
    return rand() % (max - min + 1) + min;
}

QVariant createModelData(){
    return QVariant::fromValue(new QGanttData);
}


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    qmlRegisterUncreatableType<QAbstractRangeModel>(
                "Gantt", 1, 0, "AbstractRangeModel", "AbstractRangeModel is of abstract type.");
    qmlRegisterType<QRangeView>(     "Gantt", 1, 0, "RangeView");
    qmlRegisterType<QGanttModel>(    "Gantt", 1, 0, "GanttModel");
    qmlRegisterType<QGanttModelItem>("Gantt", 1, 0, "GanttModelItem");
    qmlRegisterType<QGanttData>(     "Gantt", 1, 0, "GanttData");
    qmlRegisterType<QGanttModelList>("Gantt", 1, 0, "GanttModelList");

    QGanttModelList modelList(CONFIGURATION_MODEL_SIZE);
    //MyTestModel* myTestModel = new MyTestModel();

    int numRows = 15;
    for( int i = 0; i < numRows; ++i ){
        QGanttModel* m = new QGanttModel;
        m->setItemDataFactoryFunction(&createModelData);
        m->setContentWidth(CONFIGURATION_MODEL_SIZE);

        int pos = 0, length = 0;
        while ( pos < CONFIGURATION_MODEL_SIZE - 320 /*1200*/ ){
            pos   += randBetween(40, 300);
            length = randBetween(40, 120);

            QGanttModelItem *testItem = new QGanttModelItem(pos, length, m);
            QGanttData *testData = new QGanttData(m);
            testData->setColor(QColor::fromRgb(255,  100, i * (255 / numRows)) );
            testData->setLabel("aa " + QString::number(i) + " " + testItem->uuid().mid(1, 6));
            MyTestClass* myTestClass = new MyTestClass(m);
            myTestClass->setMyString("t: " + QString::number(i) + " " + QString::number(pos));
            QVariant var = QVariant::fromValue(myTestClass);
            testData->setVariant(var);
            testItem->setData(QVariant::fromValue(testData));

            //m->insertItem(pos, length);
            m->insertItem(testItem);
            //myTestModel->insertItem(i, testItem);
            pos   += length;

            //QGanttData* testFDX = testItem->data().value<QGanttData*>();
            //qDebug() << "FDX FDX FDX" << testFDX->label();
        }

        modelList.appendModel(m);
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("ganttModelList", &modelList);
    //engine.rootContext()->setContextProperty("myTestModel", myTestModel);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
