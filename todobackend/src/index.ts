import express from 'express';
import prisma from './prisma';
import { Request, Response } from 'express';

const app = express();


app.use(express.json());

app.get('/', async (req: Request, res: Response) => {
    try {
        const todos = await prisma.todo.findMany();
        res.json(todos);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Internal server error' });
    }
})

app.post('/', async (req: Request, res: Response) => {
    try {
        const { title, description, completed } = req.body;
        const todo = await prisma.todo.create({
            data: {
                title,
                description,
                completed
            }
        });
        res.status(201).json(todo);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Internal server error' });
    }
})

app.delete('/:id', async (req: Request, res: Response) => {
    
    try {
        const { id } = req.params;
        await prisma.todo.delete({
            where: { id: Number(id) }
        });
        res.status(204).send();
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Internal server error' });
    }
})

app.listen(3000, () => {
    console.log("Listening on port 3000");

})